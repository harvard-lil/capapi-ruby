# A Ruby wrapper for CAPAPI

``` ruby
require 'capapi'

Capapi.api_base = ENV["CAPAPI_BASE"] || "https://api.case.law"
Capapi.api_key = ENV["CAPAPI_KEY"]
Capapi.max_network_retries = ENV["CAPAPI_MAX_RETRIES"] || 3

cap_case = Capapi::Case.retrieve(183149)
# => #<Capapi::Case:0x3fc711c28c0c id=183149> JSON: {
#  "id": 183149,
#  "url": "https://api.case.law/v1/cases/183149/",
#  "name": "Janie MEALAND, Plaintiff-Appellant, v. EASTERN NEW MEXICO MEDICAL CENTER, Defendant-Appellee",
#  "name_abbreviation": "Mealand v. Eastern New Mexico Medical Center",
#  "decision_date": "2001-08-29",
#  "docket_number": "No. 20,160",
#  "first_page": "65",
#  "last_page": "76",
#  "citations": [
#    {"type":"parallel","cite":"2001-NMCA-089; 33 P.3d 285"},
#    {"type":"official","cite":"131 N.M. 65"}
#  ],
#  "volume": {"url":"https://api.case.law/v1/volumes/32044066191693/","volume_number":"131","barcode":32044066191693},
#  "reporter": {"id":554,"url":"https://api.case.law/v1/reporters/554/","full_name":"New Mexico Reports"},
#  "court": {"id":9025,"url":"https://api.case.law/v1/courts/nm-ct-app/","slug":"nm-ct-app","name":"Court of Appeals of New Mexico","name_abbreviation":"N.M. Ct. App."},
#  "jurisdiction": {"id":52,"url":"https://api.case.law/v1/jurisdictions/nm/","slug":"nm","name":"N.M.","name_long":"New Mexico","whitelisted":false}
# }

# calling .casebody will make a second API call if casebody was not fetched
# with the initial request; the result will be cached for subsequent calls
cap_case.casebody
# => #<Capapi::CapapiObject:0x3fc70e3e04a8> JSON: {
#  "data": {"head_matter":"Court of Appeals of New Mexico.\nNo. 20,160.\n2001-NMCA-089\n33 P.3d 285\nJanie MEALAND, Plaintiff-Appellant, v. EASTERN NEW MEXICO MEDICAL CENTER, Defendant-Appellee.\nAug. 29, 2001.\nCertiorari Denied, No. 27,145, Oct. 18,20...

# fetch the case with casebody all at once
cap_case = Capapi::Case.retrieve(id: 183149, full_case: "true", body_format: "html")

cap_court = cap_case.court
# => #<Capapi::Court:0x3fc7103543d4 id=9025> JSON: {
#  "id": 9025,
#  "url": "https://api.case.law/v1/courts/nm-ct-app/",
#  "slug": "nm-ct-app",
#  "name": "Court of Appeals of New Mexico",
#  "name_abbreviation": "N.M. Ct. App."
# }

cap_court_cases = cap_court.cases
# => #<Capapi::ListObject:0x3fc70e344e68> JSON: {
#  "count": 6896,
#  "next": "https://api.case.law/v1/cases/?court=nm-ct-app&cursor=cD0xOTY4LTA3LTEyJm89MTM%3D",
#  "previous": null,
#  "results": [
#    {"id":2735820,"url":"https://api.case.law/v1/cases/2735820/","name":"STATE of New Mexico, Plaintiff-Appellee, v. Carl C. WEDDLE, Defendant-Appellant","name_abbreviation":"State v.

# limit the number of results per page
cap_court_cases = cap_court.cases(page_size: 2)

# returns the next page of results
cap_court_cases.next_page

# returns the previous page of results
cap_court_cases.previous_page

# loop over each case in the fetched set
cap_court_cases.each {|cap_case| }

# loop over each case, fetching more pages of results until the API
# stops returning new pages
cap_court_cases.auto_paging_each {|cap_case| }

# returns false when the results set is empty
cap_court_cases.empty?

# see the named API resources for further addressable objects:
# https://github.com/leppert/capapi-ruby/blob/master/lib/capapi.rb#L31-L37
```

