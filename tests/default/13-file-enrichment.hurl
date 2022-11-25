###
# Get access_token from auth-server
###
POST https://a-rft.us-east-1.ris-insus-rooftop-dev-v3.lexisnexisrisk.io/mapview/uaa/oauth/token
Accept: application/json

[BasicAuth]
reformatter: Reformatter123

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
customerNumber: acme
accountNumber: 012345680
ingestType: FILE_ENRICHMENT
[MultipartFormData]
file: file,tests/test-data/file_enrichment_test.csv;

HTTP/* 200

[Captures]
filename: jsonpath "$.filename"


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
customerNumber: acme
accountNumber: 012345680
ingestType: FILE_ENRICHMENT
fileName: {{filename}}

HTTP/* 200
[Asserts]
jsonpath "$.fileStatus" == "FILE_ENRICHMENT_COMPLETE"
jsonpath "$.fileName" == {{filename}}
