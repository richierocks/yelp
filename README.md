<!-- README.md is generated from README.Rmd. Please edit that file -->
yelp
====

This R package provides access to the [Yelp API, version 3](https://www.yelp.com/developers/documentation/v3).

Installation and setup
----------------------

To use this package, you must install it and get an access token for the API.

### Package installation

To install the package, you first need *devtool* installed.

``` r
install.packages("devtools")
```

``` r
devtools::install_github("richierocks/yelp")
```

### Getting the client ID and client secret

To gain access to the API, you have to [register with Yelp](https://www.yelp.com/signup), log in, and [create your own app](https://www.yelp.com/developers/v3/manage_app). This takes 5 to 10 minutes of pointing and clicking. It's reasonably self-explanatory, and there are more details on the [API Authentication](https://www.yelp.com/developers/documentation/v3/authentication) page.

Once you have registered, make a note of your *client ID* and *client secret*.

### Getting and storing an access token

You use the client ID and client secret to get an access token.

``` r
access_token <- get_access_token(client_id, client_secret)
```

This access token can be passed into individual calls to the API, or you can store it so the package will automatically find it. `store_access_token(access_token)` will store it for the R session, or you can use your operating system tools to set a `YELP.ACCESS_TOKEN` environment variable to store it permanently.

Usage
-----

To search for businesses close to a specific location, call `business_search()` with a string giving a search term and either a string describing a location or numbers giving latitude and longitude.

``` r
library(yelp)
business_search("beauty salon", "los angeles")
#> # A tibble: 20 x 24
#>                                                     id
#>                                                  <chr>
#>  1                   arianna-hair-boutique-los-angeles
#>  2                  hair-star-total-beauty-los-angeles
#>  3                       kote-beauty-house-los-angeles
#>  4              m-hair-and-beauty-salon-los-angeles-12
#>  5                       katy-beauty-salon-los-angeles
#>  6                       prado-hair-studio-los-angeles
#>  7              beauty-secret-hair-salon-los-angeles-2
#>  8                      atelier-by-tiffany-los-angeles
#>  9                        the-avenue-salon-los-angeles
#> 10                    olympia-beauty-salon-los-angeles
#> 11     kim-sun-young-hair-and-beauty-salon-los-angeles
#> 12              beauty-creations-the-salon-los-angeles
#> 13                 stephanies-beauty-salon-los-angeles
#> 14                         the-fig-salon-los-angeles-3
#> 15                     ruthys-beauty-salon-los-angeles
#> 16 adrianas-beauty-salon-and-barber-shop-los-angeles-2
#> 17            paulas-chic-image-hair-salon-los-angeles
#> 18                  be-glamorous-by-brenda-los-angeles
#> 19                beautify-by-vickarobella-los-angeles
#> 20                           industry-dtla-los-angeles
#> # ... with 23 more variables: name <chr>, image_url <chr>,
#> #   is_closed <lgl>, url <chr>, review_count <int>,
#> #   category_aliases <list>, category_titles <list>, rating <dbl>,
#> #   latitude <dbl>, longitude <dbl>, transactions <list>, price <chr>,
#> #   address1 <chr>, address2 <chr>, address3 <chr>, city <chr>,
#> #   zip_code <chr>, state <chr>, country <chr>, display_address <list>,
#> #   phone <chr>, display_phone <chr>, distance_m <dbl>
```
