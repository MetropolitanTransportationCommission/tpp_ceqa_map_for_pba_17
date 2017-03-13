--Floor area ratio = (total amount of usable floor area that a building has, zoning floor area) / (area of the plot)

--need to get square footages from the buildings table to get far
--assumed residential unit size is 1000 sq ft. see:
--https://github.com/MetropolitanTransportationCommission/bayarea_urbansim/blob/master/baus/variables.py#L786
--unclear if this includes common area. will assume that it does. 

create view UrbanSim.Parcels_Building_Square_Footage as
SELECT  b.parcel_id,
		sum(b.residential_units)*1000 as estimated_residential_square_feet
  FROM  DEIR2017.UrbanSim.RUN7224_BUILDING_DATA_2040 as b
		group by b.parcel_id;

--need to add units/acre
--then group by taz_id and average

CREATE VIEW UrbanSim.Parcels_FAR_Units_Per_Acre AS
SELECT  (CASE WHEN p.acres = 0 THEN NULL 
			ELSE pb.estimated_residential_square_feet /  
			(p.acres*43560) END) as far_estimate,
		(CASE WHEN p.acres = 0 THEN NULL 
			ELSE Y2040.total_residential_units/p.acres 
			END) as units_per_acre,
		pb.estimated_residential_square_feet as est_res_sq_ft,
		p.PARCEL_ID,
		p.tpa_objectid,
		p.taz_id,
		p.superd_id
  FROM  DEIR2017.UrbanSim.Parcels_Building_Square_Footage as pb JOIN
		DEIR2017.UrbanSim.Parcels as p ON pb.parcel_id = p.parcel_id JOIN
		UrbanSim.RUN7224_PARCEL_DATA_2040 AS y2040 ON p.PARCEL_ID = y2040.parcel_id;
GO

create view UrbanSim.Parcels_FAR_Units_Per_Acre_SP as
SELECT  pb.estimated_residential_square_feet as est_res_sq_ft,
		pb.units_per_acre,
		pb.far_estimate,
		p.OBJECTID,
		p.PARCEL_ID,
		p.tpa_objectid,
		p.taz_id,
		p.superd_id,
		pc.Centroid
  FROM  DEIR2017.UrbanSim.Parcels_FAR_Units_Per_Acre as pb
		JOIN DEIR2017.UrbanSim.Parcels as p 
			ON pb.parcel_id = p.parcel_id
		JOIN DEIR2017.UrbanSim.Parcels_Centroid_Only pc
			ON p.parcel_id = pb.parcel_id;

GO

---create non-zero view of above

CREATE VIEW UrbanSim.Parcels_FAR_Units_Per_Acre_Non_Zero AS
SELECT  far_estimate,
		units_per_acre,
		estimated_residential_square_feet,
		PARCEL_ID,
		tpa_objectid,
		taz_id,
		superd_id
  FROM  DEIR2017.UrbanSim.Parcels_FAR_Units_Per_Acre
  		WHERE units_per_acre > 0;

GO