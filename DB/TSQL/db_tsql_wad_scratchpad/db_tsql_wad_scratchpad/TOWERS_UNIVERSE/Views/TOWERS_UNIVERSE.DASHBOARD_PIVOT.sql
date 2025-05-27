CREATE VIEW [TOWERS_UNIVERSE].[DASHBOARD_PIVOT] AS
SELECT
    CAST(MASTER_TOWER_ID AS NVARCHAR(20)) AS 'Master Tower ID',
    CASE 
        WHEN ISNULL(IN_FOOTPRINT, '') <> '' THEN 'True'
        ELSE 'False' 
    END AS 'In Footprint',
    CASE 
        WHEN ISNULL(FRONTIER_CONNECTED_TOWER, '') <> '' THEN 'True'
        ELSE 'False' 
    END AS 'Frontier Fiber Fed',
    CASE 
        WHEN ISNULL(TENANT_ATT, '') <> '' THEN 'True'
        ELSE 'False' 
    END AS 'AT&T Tenant',
    CASE 
        WHEN ISNULL(TENANT_VERIZON, '') <> '' THEN 'True'
        ELSE 'False' 
    END AS 'Verizon Tenant',
    CASE 
        WHEN ISNULL(TENANT_TMOBILE, '') <> '' THEN 'True'
        ELSE 'False' 
    END AS 'T-Mobile Tenant',
    CASE 
        WHEN ISNULL(TENANT_OTHERS, '') <> '' THEN 'True'
        ELSE 'False' 
    END AS 'Other Tenant',
    CASE 
        WHEN ISNULL(FRONTIER_CIRCUIT_ID_ATT, '') <> '' THEN 'True' 
        ELSE 'False'
    END AS 'AT&T Billed',
    CASE 
        WHEN ISNULL(FRONTIER_CIRCUIT_ID_VERIZON, '') <> '' THEN 'True'
        ELSE 'False'
    END AS 'Verizon Billed',
    CASE 
        WHEN ISNULL(FRONTIER_CIRCUIT_ID_TMOBILE, '') <> '' THEN 'True'
        ELSE 'False'
    END AS 'T-Mobile Billed',
    CASE 
        WHEN ISNULL(FRONTIER_CIRCUIT_ID_OTHER, '') <> '' THEN 'True'
        ELSE 'False'
    END AS 'Other Billed',
    TOWER_OWNER AS 'Tower Owner',
    TOWER_NAME AS 'Tower Name',
    FROGS_WIRECENTER AS 'FROGS Wirecenter',
    CAST(CENSUS_BLOCK_CODE_2019 AS NVARCHAR(20)) AS 'Census Block Code 2019',
    CAST(CENSUS_BLOCK_CODE_2020 AS NVARCHAR(20)) AS 'Census Block Code 2020',
    TOWER_STATE AS 'Tower State',
    TOWER_ADDRESS AS 'Tower Address',
    ADDRESS_CITY AS 'Tower City',
    TOWER_TYPE1 AS 'Tower Type 1',
    TOWER_TYPE2 AS 'Tower Type 2',
    CAST(TOWER_HEIGHT AS FLOAT) AS 'Tower Height',
    CAST(TOWER_ELEVATION AS FLOAT) AS 'Tower Elevation',
    MACRO_OR_SMALL_CELL AS 'Macro or Small Cell',
    MORPHOLOGY AS 'Morphology',
    CAST(DISTANCE_TO_FTR_FIBER_FEET AS FLOAT) AS 'Distance to Frontier Fiber (in Feet)',
    SITE_ID_ATT AS 'AT&T Site ID',
    SITE_ID_VERIZON AS 'Verizon Site ID',
    SITE_ID_TMOBILE AS 'T-Mobile Site ID',
    SITE_ID_OTHER AS 'Other Site ID',
    ACTIVE_DISCONNECTED_INDICATOR AS 'Active/Disconnected Indicator',
    CAST(LATITUDE AS FLOAT) AS 'Latitude',
    CAST(LONGITUDE AS FLOAT) AS 'Longitude',
    IMPORT_FILE_IDS_OF_SITES_ON_TOWER AS 'Import File IDs of Sites on Tower',
    CAST(LATA AS INT) AS 'LATA',
    MAXIMUMSPEED AS 'Maximum Speed',
    MAXIMUMQUALITYOFSERVICE AS 'Maximum Quality of Service',
    FUTUREHBEWCSPEED AS 'Future HBE WC Speed',
    PLANNEDHBETIMEFRAME AS 'Planned HBE Timeframe',
    HBE_STATUS AS 'HBE Status',
    CAST(HBE_YEAR AS INT) AS 'HBE Year',
    CAST(HBE_QTR AS INT) AS 'HBE Quarter',
    CAST(HBE_DEPLOYMENT_LOCKED AS INT) AS 'HBE Deployment Locked',
    CAST(FIBERCOMP_2K AS INT) AS 'Fiber Competitors Within 2K Feet',
    FIBERCOMP_2K_CARR AS 'Fiber Competitor Carriers Within 2K Feet',
    CAST(FIBERCOMP_4K AS INT) AS 'Fiber Competitors Within 4K Feet',
    FIBERCOMP_4K_CARR AS 'Fiber Competitor Carriers Within 4K Feet',
    CAST(TOTAL_NEWFIBEROSP_COSTS AS FLOAT) AS 'Total New Fiber OSP Costs',
    CAST(SPLICING_COST AS FLOAT) AS 'Splicing Cost',
    CAST(GUARDRAIL_COST AS FLOAT) AS 'Guardrail Cost',
    CAST(NID_SFP_COSTS_BELOW_1G AS FLOAT) AS 'NID SFP Costs Below 1G',
    CAST(NID_SFP_COSTS_1G_TO_10G AS FLOAT) AS 'NID SFP Costs 1G to 10G',
    CAST(NID_SFP_COSTS_ABOVE_10G AS FLOAT) AS 'NID SFP Costs Above 10G',
    CAST(TR_COSTS_BELOW_1G AS FLOAT) AS 'TR Costs Below 1G',
    CAST(TR_COSTS_1G_TO_10G AS FLOAT) AS 'TR Costs 1G to 10G',
    CAST(TR_COSTS_ABOVE_10G AS FLOAT) AS 'TR Costs Above 10G',
    SERVABLE AS Servable,
    REVIEW_STATUS AS 'Review Status',
    REVIEW_REASON AS 'Review Reason',
    ROUTE_NOTES AS 'Route Notes',
    NULLIF(CONCAT(CAST(HBE_QTR AS NVARCHAR(10)), '/', CAST(HBE_YEAR AS NVARCHAR(10))), '/') as HBE_TIMELINE,
    upvt.Attribute,
    upvt.Value
FROM
    TOWERS_UNIVERSE.TBL_LZ_TOWER_UPLOAD t
CROSS APPLY (
    VALUES
        ('In Footprint', CASE WHEN ISNULL(t.IN_FOOTPRINT, '') <> '' THEN 1 ELSE 0 END),
        ('AT&T Tenant', CASE WHEN ISNULL(t.TENANT_ATT, '') <> '' THEN 1 ELSE 0 END),
        ('Verizon Tenant', CASE WHEN ISNULL(t.TENANT_VERIZON, '') <> '' THEN 1 ELSE 0 END),
        ('T-Mobile Tenant', CASE WHEN ISNULL(t.TENANT_TMOBILE, '') <> '' THEN 1 ELSE 0 END),
        ('Other Tenant', CASE WHEN ISNULL(t.TENANT_OTHERS, '') <> '' THEN 1 ELSE 0 END)
) AS upvt(Attribute, Value);