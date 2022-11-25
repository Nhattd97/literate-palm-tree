###
# Get access_token from auth-server
###
POST https://a-rft.us-east-1.ris-insus-rooftop-dev-v3.lexisnexisrisk.io/mapview/uaa/oauth/token
Accept: application/json

[BasicAuth]
claim-ingest: ClaimIngest123

[QueryStringParams]
grant_type: client_credentials

HTTP/* 200
[Asserts]
jsonpath "$.token_type" == "bearer"

[Captures]
access_token: jsonpath "$.access_token"


###
# Upload file to S3
###
POST https://a-rft.us-east-1.ris-insus-rooftop-dev-v3.lexisnexisrisk.io/mapview/filewatch/file/test/upload
Authorization: Bearer {{access_token}}
Accept: application/json
Content-Type: multipart/form-data;

[QueryStringParams]
customerNumber: acmeus
accountNumber: 011234560
ingestType: CLAIM_REFORMATTER
[MultipartFormData]
file: file,tests/test-data/acmeusc_claim_test.csv;

HTTP/* 200

[Captures]
filename: jsonpath "$.filename"
filenameWithoutExtension: jsonpath "$.filename" regex "(.+?)(\\.[^.]*$|$)"

[Asserts]
jsonpath "$.fileStatus" == "READY_TO_PROCESS"


###
# Check file progress
###
GET https://a-rft.us-east-1.ris-insus-rooftop-dev-v3.lexisnexisrisk.io/mapview/filewatch/file/test/status
Authorization: Bearer {{access_token}}
Accept: application/json
Content-Type: application/json

[Options]
retry: true
retry-interval: 60000
retry-max-count: 5

[QueryStringParams]
customerNumber: acmeus
accountNumber: 011234560
ingestType: CLAIM_REFORMATTER
fileName: {{filename}}

HTTP/* 200
[Asserts]
jsonpath "$.fileStatus" == "CLAIM_INGEST_COMPLETE"
jsonpath "$.fileLocked" == false
jsonpath "$.fileName" == "{{filenameWithoutExtension}}.xml"


###
# Check data is inserted to ES
###
POST https://a-rft.us-east-1.ris-insus-rooftop-dev-v3.lexisnexisrisk.io/mapview/claim/query/customer
Authorization: Bearer {{access_token}}
Accept: application/json
Content-Type: application/json

[QueryStringParams]
customerNumber: acmeus
accountNumber: 011234560

{
	"queryType": "claimsearch",
	"term": "H7W1941001",
	"guid": ""
}

HTTP/* 200
[Asserts]
jsonpath "$.total" >= 1
jsonpath "$.claims[0].claimNumber" == "H7W1941001"