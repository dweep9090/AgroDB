1. Find  most common crops grown in a district

SELECT crop_id
FROM Produces
WHERE district_no = '01' and state_no='01'  
GROUP BY crop_id
HAVING COUNT(DISTINCT village_no) = (
    SELECT MAX(village_count)
    FROM (
        SELECT crop_id, COUNT(DISTINCT village_no) AS village_count
        FROM Produces
        WHERE district_no = '01' and state_no='01'
        GROUP BY crop_id
    ) AS VillageCounts
);



2. Details of all people related to farming in a village

SELECT b.buyer_name AS person_name, b.buyer_contact_no AS contact_no, 'Buyer' AS role
FROM Buyer AS b
JOIN Village AS v 
ON (b.village_no = v.village_no
AND b.district_no = v.district_no
AND b.state_no = v.state_no)
WHERE v.village_name = 'Kakori'

UNION

SELECT l.landlord_name AS person_name, l.landlord_contact_no AS contact_no, 'Landlord' AS role
FROM Landlord AS l
JOIN Village AS v
ON (l.village_no = v.village_no
AND l.district_no = v.district_no
AND l.state_no = v.state_no)
WHERE v.village_name = 'Kakori'

UNION

SELECT lb.labour_name AS person_name, lb.contact_no AS contact_no, 'Labour' AS role
FROM Labour AS lb
JOIN Village AS v
ON (lb.work_in_village = v.village_no
AND lb.work_in_district = v.district_no
AND lb.work_in_state = v.state_no)
WHERE v.village_name = 'Kakori'



3.Target production of all the crops grown in a district


		
SELECT c.crop_name, SUM(t.quantity) AS total_target_quantity
FROM TARGET AS t
JOIN CROP AS c ON (t.crop_id = c.crop_name)
JOIN DISTRICT AS d ON (t.district_no = d.district_no 
                AND t.state_no = d.state_no)
WHERE d.district_name = 'Lucknow' 
GROUP BY c.crop_name;


4. Target production of all crops grown across all the districts of a state


SELECT c.crop_name, d.district_name, SUM(t.quantity) AS total_target_quantity
FROM TARGET AS t
JOIN CROP AS c ON (t.crop_id = c.crop_name)
JOIN DISTRICT AS d ON (t.district_no = d.district_no 
                AND t.state_no = d.state_no)
JOIN STATE_ AS s ON d.state_no = s.state_no
WHERE s.state_name = 'Gujarat' 
GROUP BY c.crop_name, d.district_name


5. Find the total number of tenants and landlords in each village

SELECT 
    V.village_name, 
    D.district_name,  
    S.state_name,     
    (SELECT COUNT(*) FROM Tenant T WHERE T.village_no = V.village_no and T.district_no=V.district_no and T.state_no=V.state_no) AS tenant_count,
    (SELECT COUNT(*) FROM Landlord L WHERE L.village_no = V.village_no and L.district_no=V.district_no and L.state_no=V.state_no) AS landlord_count
FROM 
    Village V
JOIN 
    District D ON (V.district_no = D.district_no AND V.state_no = D.state_no) 
JOIN 
    State_ S ON (V.state_no = S.state_no);


6. There is a need for laborers in the village ‘Kakori’. Find laborers who are not hired and can grow crops that are grown in the village ‘Kakori’. Also, laborers should not be from the village ‘Kakori’.

SELECT DISTINCT l.labour_name, l.contact_no
FROM Labour AS l
JOIN Can_grow AS cg ON l.contact_no = cg.labour_id
JOIN Produces AS p ON p.crop_id = cg.crop_id
JOIN Village AS v ON (p.village_no = v.village_no 
                      AND p.district_no = v.district_no 
                      AND p.state_no = v.state_no)
WHERE v.village_name = 'Kakori'
AND l.contact_no NOT IN (
    SELECT lh.labour 
    FROM Landlord_hires_labour AS lh
    UNION
    SELECT th.labour 
    FROM Tenant_hires_labour AS th
)
EXCEPT
SELECT l.labour_name, l.contact_no
FROM Labour AS l
JOIN Village AS v2 ON (l.work_in_village = v2.village_no 
                       AND l.work_in_district = v2.district_no 
                       AND l.work_in_state = v2.state_no)
WHERE v2.village_name = 'Kakori';






7. Find  laborers who can handle machinery  and can work for 28 hours per week in the village ‘Kakori’

SELECT 
    ftable.labour_name,
    ftable.labour_contact_no
FROM 
    (
        SELECT 
            rll.labour_name AS labour_name,
            rll.labour_contact_no AS labour_contact_no,
            rll.specification AS specification,
            rll.work_hours_under_landlord AS work_hours_under_landlord,
            SUM(COALESCE(THL.work_hour_per_week, 0)) AS work_hours_under_tenant,
            rll.working_hours AS working_hours
        FROM 
            (
                SELECT 
                    L.labour_name AS labour_name,
                    L.contact_no AS labour_contact_no,
                    LS.specification AS specification,
                    SUM(COALESCE(LHL.work_hour_per_week, 0)) AS work_hours_under_landlord,
                    L.working_hours AS working_hours
                FROM 
                    Labour AS L
                JOIN 
                    Labour_Specification AS LS ON L.contact_no = LS.Labour_id
                JOIN 
                    Village AS V ON (L.work_in_village = V.village_no 
                                    AND L.work_in_district = V.district_no 
                                    AND L.work_in_state = V.state_no)
                LEFT JOIN 
                    Landlord_hires_labour AS LHL ON L.contact_no = LHL.labour
                WHERE 
                    V.village_name = 'Kakori' 
                    AND LS.specification = 'machine manage'
                GROUP BY 
                    L.labour_name, L.contact_no, LS.specification, L.working_hours
            ) AS rll
        LEFT JOIN 
            Tenant_hires_labour AS THL ON rll.labour_contact_no = THL.labour
        GROUP BY 
            rll.labour_name, 
            rll.labour_contact_no, 
            rll.specification, 
            rll.work_hours_under_landlord, 
            rll.working_hours
    ) AS ftable
WHERE 
    working_hours - (work_hours_under_landlord + work_hours_under_tenant) >= 28;







8. Let’s say a farmer wants to grow ‘Cotton’ on his land but if the district wise production of ‘Rice’ has exceeded 70% of its target then list all the crops that can be grown on his land along with its percentage of target achieved district wise in order to avoid overproduction of a particular crop.

SELECT DISTINCT 
    g.crop_id,
    (dp.quantity * 100.0) / dt.tquantity AS percent_target_reached
FROM 
    Land l
JOIN 
    Grows_on g ON l.soil_type = g.soil_id
JOIN 
    district_production dp ON dp.district_no = l.district_no
                           AND dp.state_no = l.state_no
		    AND dp.crop_id = g.crop_id
JOIN 
    (SELECT district_no, state_no, crop_id, SUM(quantity) AS tquantity
     FROM TARGET
     GROUP BY district_no, state_no, crop_id) dt
    on dp.district_no = dt.district_no
    AND dp.state_no = dt.state_no
    AND dp.crop_id = dt.crop_id
WHERE 
    l.land_no = '03' 
    AND l.village_no = '01' 
    AND l.district_no = '01' 
    AND l.state_no = '01'
    AND g.crop_id != 'Cotton'
    AND 'Cotton' IN (
	       SELECT dp.crop_id
		FROM District_production AS dp
		JOIN (
               SELECT district_no, state_no, crop_id, SUM(quantity) AS district_target
		  FROM Target
		    GROUP BY district_no, state_no, crop_id
            		    ) AS dt ON dp.district_no = dt.district_no
			       AND dp.state_no = dt.state_no                            					       AND dp.crop_id = dt.crop_id
			WHERE (dp.quantity * 100) / dt.district_target >=70
    )
ORDER BY 
    percent_target_reached DESC;




9. Find the landlord name and contact number who owns land in more than one village.

SELECT 
    Ld.landlord_name, 
    Ld.landlord_contact_no,
    COUNT(DISTINCT L.village_no) AS village_count
FROM 
    Landlord AS Ld
JOIN 
    Land AS L ON Ld.landlord_contact_no = L.landlord
GROUP BY 
    Ld.landlord_name, Ld.landlord_contact_no
HAVING 
    COUNT(DISTINCT L.village_no) > 1;


10. Find All Buyers for Land Owned by a Specific Landlord


SELECT b.buyer_name, b.buyer_contact_no, v.village_name
FROM Buyer b
JOIN Village v on b.village_no = v.village_no and  b.district_no = v.district_no and b.state_no=v.state_no 
JOIN Wants w ON b.buyer_contact_no = w.buyer_contact_no
JOIN Land l ON w.land_no = l.land_no AND w.village_no = l.village_no 
            AND w.district_no = l.district_no AND w.state_no = l.state_no
WHERE l.landlord = '9876543910';




11. Give the landlord name, number and address of land which satisfies a buyer’s requirement.


    First you need to register the buyer,

	SELECT LD.landlord_name, LD.landlord_contact_no, V.village_name
FROM Land AS L
JOIN Wants AS W ON (L.land_no = W.land_no 
                    AND L.village_no = W.village_no 
                    AND L.district_no = W.district_no 
                    AND L.state_no = W.state_no)
JOIN Landlord AS LD ON (LD.landlord_contact_no = L.landlord)
JOIN Village AS V ON (V.village_no = LD.village_no 
                      AND V.district_no = LD.district_no 
                      AND V.state_no = LD.state_no)
WHERE W.buyer_contact_no = '9876500001';



12. Top 3 Most Popular Crop Requirements among Buyers across all the districts of the state ‘Uttar Pradesh’.

	SELECT BC.crops_offered, COUNT(BC.buyer_contact_no) AS total_demand
FROM Buyer_crops AS BC
JOIN Buyer AS B ON BC.buyer_contact_no = B.buyer_contact_no
WHERE B.state_no = '01'
GROUP BY BC.crops_offered
ORDER BY total_demand DESC
LIMIT 3
;






13. Give contribution of different villages of the districts of ’Uttar Pradesh’ in a production of a crop say , ‘Rice’.

SELECT vp.village_no, vp.district_no, vp.state_no, vp.crop_id, v.village_name AS village,
           (vp.quantity * 100.0 / dt.district_quantity) AS contribution_percentage
    FROM village_production AS vp
    JOIN (
        SELECT quantity AS district_quantity
        FROM district_production
        WHERE 	crop_id = 'Rice' 
AND district_no = '01'
 AND state_no = '01'
    ) AS dt ON vp.district_no = '01'
             AND vp.state_no = '01'
             AND vp.crop_id = 'Rice'
    JOIN Village AS v ON v.village_no = vp.village_no
                      AND v.district_no = vp.district_no
                      AND v.state_no = vp.state_no



14. Find all crops produced in the village Kakori of  district lucknow and state uttar pradesh,  with their respective quantity produced.
	
	
select village_name, district_name, state_name, crop_id,vp.quantity from village_production as vp 
join village as v on vp.village_no=v.village_no
				   and vp.district_no = v.district_no
				   and vp.state_no = v.state_no
join district as d on  vp.district_no = d.district_no
				   and vp.state_no = d.state_no
join state_ as s on vp.state_no = s.state_no
where state_name = 'Uttar Pradesh' and district_name='Lucknow' and village_name='Kakori' 



15. Find landlord who are still hiring labours in a village
	
	SELECT LD.landlord_name, LD.landlord_contact_no, 
       (SUM(L.need_staff) - COALESCE(LH.hired_labour_count, 0)) AS still_required
FROM Land AS L
JOIN Landlord AS LD ON L.landlord = LD.landlord_contact_no
LEFT JOIN (
    SELECT head_farmer, COUNT(*) AS hired_labour_count
    FROM Landlord_hires_labour
    GROUP BY head_farmer
) AS LH ON LD.landlord_contact_no = LH.head_farmer
WHERE L.village_no = '01'
    AND L.district_no = '01'
    AND L.state_no = '01'
GROUP BY LD.landlord_name, LD.landlord_contact_no, LH.hired_labour_count
HAVING (SUM(L.need_staff) - COALESCE(LH.hired_labour_count, 0)) > 0;



16. Find buyer who are interested in buying land of village(04,03,01) with landlord contact given as 9991234601

SELECT b.buyer_name, b.buyer_contact_no, b.occupation
FROM wants AS w
JOIN buyer AS b ON b.buyer_contact_no = w.buyer_contact_no
JOIN land AS l ON l.land_no = w.land_no
                AND l.village_no = w.village_no
                AND l.district_no = w.district_no
                AND l.state_no = w.state_no
WHERE l.landlord = 9991234601
    AND (l.village_no = '04' AND l.district_no = '03' AND l.state_no = '01')
    AND (b.village_no != '03' AND b.district_no != '01' AND b.state_no != '01');



17. Landlord has a fertilizer urea and he wants to know whether it can be used for other crops that can be grown on his land. If yes then return crop names.

SELECT DISTINCT g.crop_id
FROM Land AS L
JOIN Grows_on AS g ON L.soil_type = g.soil_id
JOIN Requires AS R ON g.crop_id = R.crop_id
WHERE L.landlord = 6543210987
    AND R.fertilizer_id = 'Urea'
    AND L.soil_type = R.soil_id
    AND (L.village_no='01' and L.district_no='01' and L.state_no='01')




18. Find number of crops each soil support


SELECT soil_id, COUNT(DISTINCT crop_id) AS crop_count
FROM grows_on
GROUP BY soil_id
ORDER BY crop_count DESC




19. Find percentage of target that has been achieved by each crop of district (01,01) ,i.e, display (produced*100)/target for each crop of a given district.
	
	SELECT dp.crop_id, 
       (dp.quantity * 100.0 / dwt.district_target) AS percentage_target_reached 
FROM district_production AS dp
JOIN (
    SELECT district_no, state_no, crop_id, SUM(quantity) AS district_target 
    FROM TARGET 
    GROUP BY district_no, state_no, crop_id
) AS dwt 
ON dp.district_no = dwt.district_no
   AND dp.state_no = dwt.state_no
   AND dwt.crop_id = dp.crop_id
  AND dp.district_no = '01' 
  AND dp.state_no = '01';


20. I want to know the number of laborers involved in production of each crop grown in a district.

	SELECT 
    p.crop_id, 
    COUNT(lhl.labour) + COUNT(thl.labour) AS total_labour 
FROM 
    land AS lnd
JOIN 
    produces AS p ON lnd.land_no = p.land_no
                  AND lnd.village_no = p.village_no
                  AND lnd.district_no = p.district_no
                  AND lnd.state_no = p.state_no
LEFT JOIN 
    landlord_hires_labour AS lhl ON lnd.landlord = lhl.head_farmer AND lnd.temporary_landlord IS NULL
LEFT JOIN 
    tenant_hires_labour AS thl ON thl.head_farmer = lnd.temporary_landlord 
WHERE  
    lnd.district_no = '01' AND lnd.state_no = '01'
GROUP BY 
    p.crop_id
ORDER BY total_labour;



21. Find fertilizers that can be used for each crop that can be grown on ‘clay’ soil

	SELECT c.crop_name, f.fertilizer_name
FROM Crop AS c
JOIN Requires AS r ON c.crop_name = r.crop_id
JOIN Fertilizer AS f ON r.fertilizer_id = f.fertilizer_name
WHERE r.soil_id = 'clay'
ORDER BY c.crop_name;


22. Find pesticide used to treat a specific symptom in a crop.

	SELECT c.crop_name, p.pesticide_name, t.symptoms
FROM Crop AS c
JOIN Treats AS t ON c.crop_name = t.crop_id
JOIN Pesticide AS p ON t.pesticide_id = p.pesticide_name
WHERE t.symptoms LIKE '%weeds%'
ORDER BY c.crop_name;




