SELECT DISTINCT 'DELETE' "METADATA"
	, 'AssignmentSupervisor' "AssignmentSupervisor"
	, TO_CHAR(PAAM.ASSIGNMENT_ID) "AssignmentId"
	, TO_CHAR(PASF.ASSIGNMENT_SUPERVISOR_ID) "AssignmentSupervisorId"
	, TO_CHAR(PASF.EFFECTIVE_START_DATE, 'YYYY/MM/DD') "EffectiveStartDate"
	, HIKM.SOURCE_SYSTEM_OWNER "SourceSystemOwner"
	, HIKM.SOURCE_SYSTEM_ID "SourceSystemId"
	, PAPF.PERSON_NUMBER "PersonNumber(for reference only)" --for reference only
	, PAAM.ASSIGNMENT_NUMBER "AssignmentNumber"
	, PASF.PRIMARY_FLAG "PrimaryFlag"
	, PASF.MANAGER_TYPE "ManagerType"
	, PAPF_MGR.PERSON_NUMBER "ManagerPersonNumber"
	, PAAM_MGR.ASSIGNMENT_NUMBER "ManagerAssignmentNumber"
	, PAB.ACTION_CODE "ActionCode(for reference only)" --for reference only
FROM PER_ALL_PEOPLE_F PAPF
	, PER_ALL_ASSIGNMENTS_M PAAM
	, (PER_ASSIGNMENT_SUPERVISORS_F PASF
		LEFT JOIN PER_ACTION_OCCURRENCES PAO
		ON PAO.ACTION_OCCURRENCE_ID = PASF.ACTION_OCCURRENCE_ID)
			LEFT JOIN PER_ACTIONS_B PAB
			ON PAB.ACTION_ID = PAO.ACTION_ID
	, HRC_INTEGRATION_KEY_MAP HIKM
	, PER_ALL_PEOPLE_F PAPF_MGR
	, PER_ALL_ASSIGNMENTS_M PAAM_MGR
WHERE 1 = 1
	AND PAPF.PERSON_ID = PAAM.PERSON_ID
	AND PAAM.ASSIGNMENT_ID = PASF.ASSIGNMENT_ID
	AND HIKM.SURROGATE_ID = PASF.ASSIGNMENT_SUPERVISOR_ID
	AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
	AND SYSDATE BETWEEN PASF.EFFECTIVE_START_DATE AND PASF.EFFECTIVE_END_DATE
	AND PAAM.PRIMARY_FLAG = 'Y'
	AND PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
	AND PAAM.ASSIGNMENT_TYPE NOT LIKE '%T'
	AND PAAM.EFFECTIVE_START_DATE = (SELECT DISTINCT MAX(PAAM2.EFFECTIVE_START_DATE) FROM PER_ALL_ASSIGNMENTS_M PAAM2 WHERE PAAM2.PERSON_ID = PAAM.PERSON_ID)
	AND HIKM.OBJECT_NAME = 'AssignmentSupervisor'
	AND PASF.MANAGER_ID = PAPF_MGR.PERSON_ID
	AND SYSDATE BETWEEN PAPF_MGR.EFFECTIVE_START_DATE AND PAPF_MGR.EFFECTIVE_END_DATE
	AND PASF.MANAGER_ASSIGNMENT_ID = PAAM_MGR.ASSIGNMENT_ID
	AND SYSDATE BETWEEN PAAM_MGR.EFFECTIVE_START_DATE AND PAAM_MGR.EFFECTIVE_END_DATE
	AND PAAM_MGR.PRIMARY_FLAG = 'Y'
	AND PAAM_MGR.EFFECTIVE_LATEST_CHANGE = 'Y'
	AND PAAM_MGR.ASSIGNMENT_TYPE NOT LIKE '%T'
	AND PAAM_MGR.EFFECTIVE_START_DATE = (SELECT DISTINCT MAX(PAAM2.EFFECTIVE_START_DATE) FROM PER_ALL_ASSIGNMENTS_M PAAM2 WHERE PAAM2.PERSON_ID = PAAM_MGR.PERSON_ID)
ORDER BY PAPF.PERSON_NUMBER
