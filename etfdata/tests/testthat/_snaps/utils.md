# parse_aum works correctly

    Code
      result
    Output
      # A tibble: 1 x 5
        currency aum_units aum_amount aum_units_amount total_amount
        <fct>    <fct>          <dbl>            <dbl>        <dbl>
      1 GBP      m             100642          1000000 100642000000

---

    Code
      result_vec
    Output
      # A tibble: 3 x 5
        currency aum_units aum_amount aum_units_amount total_amount
        <fct>    <fct>          <dbl>            <dbl>        <dbl>
      1 GBP      m           100642            1000000 100642000000
      2 USD      bn              50.5       1000000000  50500000000
      3 EUR      <NA>           500                  1          500

