# parse_aum works correctly

    Code
      result
    Output
      # A tibble: 1 x 4
        currency aum_units aum_amount aum_units_amount
        <fct>    <fct>          <dbl>            <dbl>
      1 GBP      m             100642          1000000

---

    Code
      result_vec
    Output
      # A tibble: 3 x 4
        currency aum_units aum_amount aum_units_amount
        <fct>    <fct>          <dbl>            <dbl>
      1 GBP      m           100642            1000000
      2 USD      bn              50.5       1000000000
      3 EUR      <NA>           500                  1

