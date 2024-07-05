SELECT DISTINCT 'MERGE' "METADATA"
	, 'Assignment' "Assignment"
	, PAAM.ASSIGNMENT_NUMBER "AssignmentNumber"
	, TO_CHAR(PAAM.EFFECTIVE_START_DATE, 'YYYY/MM/DD') "EffectiveStartDate"
	, TO_CHAR(PAAM.EFFECTIVE_END_DATE, 'YYYY/MM/DD') "EffectiveEndDate"
	, (SELECT DISTINCT PAAM_WT.ASSIGNMENT_NUMBER
		FROM PER_ALL_ASSIGNMENTS_M PAAM_WT
		WHERE PAAM_WT.ASSIGNMENT_ID = PAAM.WORK_TERMS_ASSIGNMENT_ID) "WorkTermsNumber"
	, PAAM.ACTION_CODE "ActionCode"
	, PARB.ACTION_REASON_CODE "ReasonCode"
	, PAPF.PERSON_NUMBER "PersonNumber"
	, PAAM.EFFECTIVE_LATEST_CHANGE "EffectiveLatestChange"
	, PAAM.EFFECTIVE_SEQUENCE "EffectiveSequence"
	, HIKM.SOURCE_SYSTEM_ID "SourceSystemId"
	, HIKM.SOURCE_SYSTEM_OWNER "SourceSystemOwner"
FROM (PER_ALL_ASSIGNMENTS_M PAAM
	LEFT JOIN PER_ACTION_OCCURRENCES PAO
	ON PAO.ACTION_OCCURRENCE_ID = PAAM.ACTION_OCCURRENCE_ID)
		LEFT JOIN PER_ACTION_REASONS_B PARB
		ON PARB.ACTION_REASON_ID = PAO.ACTION_REASON_ID
	, PER_ALL_PEOPLE_F PAPF
	, HRC_INTEGRATION_KEY_MAP HIKM
WHERE 1 = 1
	AND PAAM.PERSON_ID = PAPF.PERSON_ID
	AND HIKM.SURROGATE_ID = PAAM.ASSIGNMENT_ID
	AND PAAM.ASSIGNMENT_TYPE NOT LIKE '%T%'
	AND PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
	--AND PAAM.PRIMARY_FLAG = 'Y'
	AND HIKM.OBJECT_NAME = 'Assignment'
	AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
	AND PAPF.PERSON_NUMBER = NVL(:PersonNumber, PAPF.PERSON_NUMBER)
ORDER BY PAPF.PERSON_NUMBER, TO_CHAR(PAAM.EFFECTIVE_START_DATE, 'YYYY/MM/DD')
