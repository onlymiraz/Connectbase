SELECT DISTINCT --STATE,
                  EVC_CKT_ID,
                  EVC_CIRCUIT,
                  --STATUS,
                  --ISSUE_STATUS,
                  UNI_CKT_ID,
                  UNI_CIRCUIT,
                  UNI_LOC_A,
                  UNI_LOC_Z,
                  ORIG_ELEMENT_NM,
                  TERM_ELEMENT_NM,
                  (SELECT NE_TYPE_NM FROM NE_TYPE NT,
                                          NETWORK_NODE NN,
                                          NS_COMPONENT NC
                   WHERE NT.NE_TYPE_ID = NN.NE_TYPE_ID
                   AND   NN.NETWORK_NODE_ID = NC.NETWORK_NODE_ID
                   AND NC.NS_COMP_ID = TERM_ELEMENT_ID) TERM_ELEMENT_TYPE,                    
                  CNL,
                  CNL_ORIG_ELEMENT_NM,
                  (SELECT NE_TYPE_NM FROM NE_TYPE NT,
                                          NETWORK_NODE NN,
                                          NS_COMPONENT NC
                   WHERE NT.NE_TYPE_ID = NN.NE_TYPE_ID
                   AND   NN.NETWORK_NODE_ID = NC.NETWORK_NODE_ID
                   AND NC.NS_COMP_ID = CNL_ORIG_ELEMENT_ID) CNL_ORIG_ELEMENT_TYPE,
                  CNL_TERM_ELEMENT_NM,
                  (SELECT NE_TYPE_NM FROM NE_TYPE NT,
                                          NETWORK_NODE NN,
                                          NS_COMPONENT NC
                   WHERE NT.NE_TYPE_ID = NN.NE_TYPE_ID
                   AND   NN.NETWORK_NODE_ID = NC.NETWORK_NODE_ID
                   AND NC.NS_COMP_ID = CNL_TERM_ELEMENT_ID) CNL_TERM_ELEMENT_TYPE,
                  CNL_CKT_XREF,
                  INL,
                  INL_ORIG_ELEMENT_NM,
                  (SELECT NE_TYPE_NM FROM NE_TYPE NT,
                                          NETWORK_NODE NN,
                                          NS_COMPONENT NC
                   WHERE NT.NE_TYPE_ID = NN.NE_TYPE_ID
                   AND   NN.NETWORK_NODE_ID = NC.NETWORK_NODE_ID
                   AND NC.NS_COMP_ID = INL_ORIG_ELEMENT_ID) INL_ORIG_ELEMENT_TYPE,
                  INL_TERM_ELEMENT_NM,
                  (SELECT NE_TYPE_NM FROM NE_TYPE NT,
                                          NETWORK_NODE NN,
                                          NS_COMPONENT NC
                   WHERE NT.NE_TYPE_ID = NN.NE_TYPE_ID
                   AND   NN.NETWORK_NODE_ID = NC.NETWORK_NODE_ID
                   AND NC.NS_COMP_ID = INL_TERM_ELEMENT_ID) INL_TERM_ELEMENT_TYPE,
                  INL_CKT_XREF,
                  RTRIM(REGEXP_SUBSTR(GPON, '[^|]+', 1, 1), '|') GPON,
                  (SELECT NS_COMP_NM
                     FROM NS_COMPONENT N
                    WHERE N.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(GPON, '[^|]+', 1, 2), '|'))
                     GPON_ORIG_ELEMENT_NM,
                  (SELECT NE_TYPE_NM FROM NE_TYPE NT,
                                          NETWORK_NODE NN,
                                          NS_COMPONENT NC
                   WHERE NT.NE_TYPE_ID = NN.NE_TYPE_ID
                   AND   NN.NETWORK_NODE_ID = NC.NETWORK_NODE_ID
                   AND NC.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(GPON, '[^|]+', 1, 2), '|')) GPON_ORIG_ELEMENT_TYPE,
                  (SELECT NS_COMP_NM
                     FROM NS_COMPONENT N
                    WHERE N.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(GPON, '[^|]+', 1, 3), '|'))
                     GPON_TERM_ELEMENT_NM,
                  (SELECT NE_TYPE_NM FROM NE_TYPE NT,
                                          NETWORK_NODE NN,
                                          NS_COMPONENT NC
                   WHERE NT.NE_TYPE_ID = NN.NE_TYPE_ID
                   AND   NN.NETWORK_NODE_ID = NC.NETWORK_NODE_ID
                   AND NC.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(GPON, '[^|]+', 1, 3), '|')) GPON_TERM_ELEMENT_TYPE,
                  GPON_CKT_XREF
    FROM (SELECT STATE,
                 EVC_CKT_ID,
                 EVC_CIRCUIT,
                 STATUS,
                 ISSUE_STATUS,
                 UNI_CKT_ID,
                 UNI_CIRCUIT,
                 UNI_LOC_A,
                 UNI_LOC_Z,
                 ORIG_ELEMENT_NM,
                 TERM_ELEMENT_ID,
                 TERM_ELEMENT_NM,
                 CNL,
                 CNL_ORIG_ELEMENT_NM,
                 CNL_ORIG_ELEMENT_ID,
                 CNL_TERM_ELEMENT_NM,
                 CNL_TERM_ELEMENT_ID,
                 CNL_CKT_XREF,
                 RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 1), '|') INL,
                 (SELECT NS_COMP_NM
                    FROM NS_COMPONENT N
                   WHERE N.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 2), '|'))
                    INL_ORIG_ELEMENT_NM,
                    RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 2), '|') INL_ORIG_ELEMENT_ID,
                 (SELECT NS_COMP_NM
                    FROM NS_COMPONENT N
                   WHERE N.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 3), '|'))
                    INL_TERM_ELEMENT_NM,
                    RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 3), '|') INL_TERM_ELEMENT_ID,
                 INL_CKT_XREF,
                 GPON_CKT_XREF,
                 (SELECT C4.EXCHANGE_CARRIER_CIRCUIT_ID || '|' || NSC4.NS_COMP_ID_PARENT || '|' || NSC4.NS_COMP_ID_CHILD || '|' || C4.CIRCUIT_DESIGN_ID
                    FROM CIRCUIT C4,
                         NS_CON_REL NS4,
                         NS_CONNECTION NSC4
                   WHERE C4.CIRCUIT_DESIGN_ID = NS4.CIRCUIT_DESIGN_ID_PARENT
                     AND NS4.CIRCUIT_DESIGN_ID_CHILD = EVC_CKT_ID
                     AND NS4.CIRCUIT_DESIGN_ID_PARENT = NSC4.CIRCUIT_DESIGN_ID
                     AND C4.EXCHANGE_CARRIER_CIRCUIT_ID != UNI_CIRCUIT
                     AND C4.CIRCUIT_DESIGN_ID != RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 4), '|')
                     AND RTRIM(C4.EXCHANGE_CARRIER_CIRCUIT_ID) != CNL
                     AND (((((((NSC4.NS_COMP_ID_PARENT = RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 2), '|')
                            AND ROWNUM = 1)
                            OR NSC4.NS_COMP_ID_CHILD = RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 2), '|')
                           AND ROWNUM = 1))
                          OR (NSC4.NS_COMP_ID_PARENT = RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 3), '|')
                          AND ROWNUM = 1)
                          OR NSC4.NS_COMP_ID_CHILD = RTRIM(REGEXP_SUBSTR(INL, '[^|]+', 1, 3), '|'))
                        AND ROWNUM = 1)
                       AND NS4.NS_CON_REL_STATUS_CD <> '4')))
                    GPON
            FROM (SELECT DISTINCT
                         STATE,
                         EVC_CKT_ID,
                         EVC_CIRCUIT,
                         STATUS,
                         ISSUE_STATUS,
                         UNI_CKT_ID,
                         UNI_CIRCUIT,
                         UNI_LOC_A,
                         UNI_LOC_Z,
                         ORIG_ELEMENT_NM,
                         TERM_ELEMENT_ID,
                         TERM_ELEMENT_NM,
                         RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 1), '|') CNL,
                         (SELECT NS_COMP_NM
                            FROM NS_COMPONENT N
                           WHERE N.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 2), '|'))
                            CNL_ORIG_ELEMENT_NM,
                            RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 2), '|') CNL_ORIG_ELEMENT_ID,
                         (SELECT NS_COMP_NM
                            FROM NS_COMPONENT N
                           WHERE N.NS_COMP_ID = RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 3), '|'))
                            CNL_TERM_ELEMENT_NM,
                         RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 3), '|') CNL_TERM_ELEMENT_ID,
                         CNL_CKT_XREF,
                         (SELECT C3.EXCHANGE_CARRIER_CIRCUIT_ID || '|' || NSC3.NS_COMP_ID_PARENT || '|' || NSC3.NS_COMP_ID_CHILD || '|' || C3.
                                 CIRCUIT_DESIGN_ID
                            FROM CIRCUIT C3,
                                 NS_CON_REL NS3,
                                 NS_CONNECTION NSC3
                           WHERE C3.CIRCUIT_DESIGN_ID = NS3.CIRCUIT_DESIGN_ID_PARENT
                             AND NS3.CIRCUIT_DESIGN_ID_CHILD = EVC_CKT_ID
                             AND NS3.CIRCUIT_DESIGN_ID_PARENT = NSC3.CIRCUIT_DESIGN_ID
                             AND C3.EXCHANGE_CARRIER_CIRCUIT_ID != UNI_CIRCUIT
                             AND RTRIM(C3.EXCHANGE_CARRIER_CIRCUIT_ID) != RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 1), '|')
                             AND (((((((NSC3.NS_COMP_ID_PARENT = RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 2), '|')
                                    AND ROWNUM = 1)
                                    OR NSC3.NS_COMP_ID_CHILD = RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 2), '|')
                                   AND ROWNUM = 1))
                                  OR (NSC3.NS_COMP_ID_PARENT = RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 3), '|')
                                  AND ROWNUM = 1)
                                  OR NSC3.NS_COMP_ID_CHILD = RTRIM(REGEXP_SUBSTR(CNL, '[^|]+', 1, 3), '|'))
                                AND ROWNUM = 1)
                               AND NS3.NS_CON_REL_STATUS_CD <> '4')))
                            INL,
                         INL_CKT_XREF,
                         GPON_CKT_XREF
                    FROM (SELECT GA.INSTANCE_VALUE_ABBREV STATE,
                                 C1.CIRCUIT_DESIGN_ID EVC_CKT_ID,
                                 C1.EXCHANGE_CARRIER_CIRCUIT_ID EVC_CIRCUIT,
                                 C1.STATUS,
                                 D.ISSUE_STATUS,
                                 NSCR.NS_CON_REL_STATUS_CD,
                                 C2.CIRCUIT_DESIGN_ID UNI_CKT_ID,
                                 C2.EXCHANGE_CARRIER_CIRCUIT_ID UNI_CIRCUIT,
                                 c2.LOCATION_ID UNI_LOC_A,
                                 c2.LOCATION_ID_2 UNI_LOC_Z,
                                 NSCP1.NS_COMP_NM ORIG_ELEMENT_NM,
                                 NSCP2.NS_COMP_ID TERM_ELEMENT_ID,
                                 NSCP2.NS_COMP_NM TERM_ELEMENT_NM,
                                 ((SELECT C.EXCHANGE_CARRIER_CIRCUIT_ID || '|' || NSC.NS_COMP_ID_PARENT || '|' || NSC.NS_COMP_ID_CHILD || '|' || C.
                                          CIRCUIT_DESIGN_ID
                                     FROM CIRCUIT C,
                                          NS_CON_REL NS,
                                          NS_CONNECTION NSC
                                    WHERE C.CIRCUIT_DESIGN_ID = NS.CIRCUIT_DESIGN_ID_PARENT
                                      AND NS.CIRCUIT_DESIGN_ID_CHILD = C1.CIRCUIT_DESIGN_ID
                                      AND NS.CIRCUIT_DESIGN_ID_PARENT = NSC.CIRCUIT_DESIGN_ID
                                      AND NSC.CIRCUIT_DESIGN_ID != C2.CIRCUIT_DESIGN_ID
                                      AND ((NSC.NS_COMP_ID_PARENT = NSC2.NS_COMP_ID_CHILD
                                         OR NSC.NS_COMP_ID_CHILD = NSC2.NS_COMP_ID_CHILD
                                         OR NSC.NS_COMP_ID_CHILD = NSC2.NS_COMP_ID_PARENT
                                         OR NSC.NS_COMP_ID_PARENT = NSC2.NS_COMP_ID_PARENT)
                                       AND ROWNUM = 1)
                                      AND NS.NS_CON_REL_STATUS_CD <> '4'))
                                    CNL,
                                 CX1.CIRCUIT_XREF_ECCKT CNL_CKT_XREF,
                                 CX2.CIRCUIT_XREF_ECCKT INL_CKT_XREF,
                                 CX3.CIRCUIT_XREF_ECCKT GPON_CKT_XREF
                            FROM CIRCUIT C1,
                                 SERV_ITEM SI,
                                 (SELECT DISTINCT *
                                    FROM (SELECT d.design_id,
                                                 d.issue_nbr,
                                                 d.serv_item_id,
                                                 d.issue_status,
                                                 ROW_NUMBER() OVER (PARTITION BY serv_item_id ORDER BY issue_status ASC) r
                                            FROM asap.design D)
                                   WHERE r = 1) D,
                                 (SELECT DISTINCT *
                                    FROM (SELECT d.location_id,
                                                 d.address_id,
                                                 d.active_ind,
                                                 ROW_NUMBER() OVER (PARTITION BY location_id ORDER BY address_id DESC) r
                                            FROM asap.net_loc_addr d
                                           WHERE active_ind = 'Y')
                                   WHERE r = 1) NLA,
                                 ADDRESS A,
                                 GA_INSTANCE GA,
                                 NS_CONNECTION NSC1,
                                 NS_CON_REL NSCR,
                                 CIRCUIT C2,
                                 (SELECT CIRCUIT_DESIGN_ID,
                                         CIRCUIT_XREF_ECCKT
                                    FROM CIRCUIT_XREF
                                   WHERE CIRCUIT_XREF_ECCKT LIKE '___CL%'
                                     AND STATUS IS NOT NULL) CX1,
                                 (SELECT CIRCUIT_DESIGN_ID,
                                         CIRCUIT_XREF_ECCKT
                                    FROM CIRCUIT_XREF
                                   WHERE CIRCUIT_XREF_ECCKT LIKE '___IL%'
                                     AND STATUS IS NOT NULL) CX2,
                                 (SELECT CIRCUIT_DESIGN_ID,
                                         CIRCUIT_XREF_ECCKT
                                    FROM CIRCUIT_XREF
                                   WHERE CIRCUIT_XREF_ECCKT LIKE '%GPON%'
                                     AND STATUS IS NOT NULL) CX3,
                                 NS_CONNECTION NSC2,
                                 NS_COMPONENT NSCP1,
                                 NS_COMPONENT NSCP2
                           WHERE C1.CIRCUIT_DESIGN_ID = NSC1.CIRCUIT_DESIGN_ID
                             AND C1.CIRCUIT_DESIGN_ID = SI.CIRCUIT_DESIGN_ID
                             AND SI.SERV_ITEM_ID = D.SERV_ITEM_ID
                             AND C1.LOCATION_ID = NLA.LOCATION_ID
                             AND NLA.ADDRESS_ID = A.ADDRESS_ID
                             AND A.GA_INSTANCE_ID_STATE_CD = GA.GA_INSTANCE_ID
                             AND NSC1.CIRCUIT_DESIGN_ID = NSCR.CIRCUIT_DESIGN_ID_CHILD
                             AND NSCR.CIRCUIT_DESIGN_ID_PARENT = C2.CIRCUIT_DESIGN_ID
                             AND C2.CIRCUIT_DESIGN_ID = NSC2.CIRCUIT_DESIGN_ID
                             AND NSC2.CIRCUIT_DESIGN_ID = CX1.CIRCUIT_DESIGN_ID(+)
                             AND NSC2.CIRCUIT_DESIGN_ID = CX2.CIRCUIT_DESIGN_ID(+)
                             AND NSC2.CIRCUIT_DESIGN_ID = CX3.CIRCUIT_DESIGN_ID(+)
                             AND NSC2.NS_COMP_ID_PARENT = NSCP1.NS_COMP_ID
                             AND NSC2.NS_COMP_ID_CHILD = NSCP2.NS_COMP_ID
                             AND (NSC1.NS_COMP_ID_PARENT = NSC2.NS_COMP_ID_PARENT
                               OR NSC1.NS_COMP_ID_CHILD = NSC2.NS_COMP_ID_PARENT
                               OR NSC1.NS_COMP_ID_CHILD = NSC2.NS_COMP_ID_CHILD)
                             AND NSCR.NS_CON_REL_STATUS_CD <> '4'
                             AND C1.CIRCUIT_DESIGN_ID IN (
'9791450'))))
                             --AND EXISTS
                               --     (SELECT CIRCUIT_DESIGN_ID
                                 --      FROM TEAM_OSS.TLS_UNI TLS
                                   --   WHERE TLS.CIRCUIT_DESIGN_ID = C2.CIRCUIT_DESIGN_ID))))
--ORDER BY STATE,
--         EVC_CIRCUIT
ORDER BY EVC_CIRCUIT
