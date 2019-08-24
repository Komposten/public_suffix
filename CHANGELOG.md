## 1.0.0

- Load suffix rule lists from strings or URIs.
- Parse URLs against suffix lists to obtain:
    - public suffix (e.g. `co.uk`)
    - root domain (e.g. `google`)
    - registrable domain (e.g. `google.co.uk`)
- Obtain results with and without private (i.e. non-ICANN/IANA) suffix rules.
- Obtain punycode encoded and decoded results (if a punycoded URL is parsed).
