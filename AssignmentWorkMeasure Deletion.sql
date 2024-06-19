SELECT DISTINCT 'DELETE' "METADATA"
	, 'AssignmentWorkMeasure' "AssignmentWorkMeasure"
	, TO_CHAR(PAAM.ASSIGNMENT_ID) "AssignmentId"
	, TO_CHAR(PAWMF.ASSIGN_WORK_MEASURE_ID) "AssignWorkMeasureId"
	, TO_CHAR(PAWMF.EFFECTIVE_START_DATE, 'YYYY/MM/DD') "EffectiveStartDate"
	, HIKM.SOURCE_SYSTEM_OWNER "SourceSystemOwner"
	, HIKM.SOURCE_SYSTEM_ID "SourceSystemId"
	, PAPF.PERSON_NUMBER "PersonNumber(for reference only)" --for reference only
	, PAAM.ASSIGNMENT_NUMBER "AssignmentNumber"
	, PAWMF.UNIT "Unit"
	, PAWMF.VALUE "Value"
	, PAB.ACTION_CODE "ActionCode(for reference only)" --for reference only
FROM PER_ALL_PEOPLE_F PAPF
	, PER_ALL_ASSIGNMENTS_M PAAM
	, (PER_ASSIGN_WORK_MEASURES_F PAWMF
		LEFT JOIN PER_ACTION_OCCURRENCES PAO
		ON PAO.ACTION_OCCURRENCE_ID = PAWMF.ACTION_OCCURRENCE_ID)
			LEFT JOIN PER_ACTIONS_B PAB
			ON PAB.ACTION_ID = PAO.ACTION_ID
	, HRC_INTEGRATION_KEY_MAP HIKM
WHERE 1 = 1
	AND PAPF.PERSON_ID = PAAM.PERSON_ID
	AND PAAM.ASSIGNMENT_ID = PAWMF.ASSIGNMENT_ID
	AND HIKM.SURROGATE_ID = PAWMF.ASSIGN_WORK_MEASURE_ID
	AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN PAWMF.EFFECTIVE_START_DATE AND PAWMF.EFFECTIVE_END_DATE
	AND PAAM.PRIMARY_FLAG = 'Y'
	AND PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
	AND PAAM.ASSIGNMENT_TYPE NOT LIKE '%T'
	AND PAAM.EFFECTIVE_START_DATE = (SELECT DISTINCT MAX(PAAM2.EFFECTIVE_START_DATE) FROM PER_ALL_ASSIGNMENTS_M PAAM2 WHERE PAAM2.PERSON_ID = PAAM.PERSON_ID)
	AND HIKM.OBJECT_NAME = 'AssignmentWorkMeasure'
ORDER BY PAPF.PERSON_NUMBER
