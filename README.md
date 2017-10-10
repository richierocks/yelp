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
#>                                                                id
#>                                                             <chr>
#>  1                                  olympic-nails-beverly-hills-2
#>  2                                       la-belle-vie-los-angeles
#>  3              beautyholic-permanent-makeup-and-nail-los-angeles
#>  4                                     ellie-and-sass-los-angeles
#>  5                                      nails-by-amie-los-angeles
#>  6                                         forty27-studio-burbank
#>  7                                          apothic-salon-burbank
#>  8                                            nail-45-los-angeles
#>  9                                       hair-by-sima-los-angeles
#> 10                                      ecospray-tanning-glendale
#> 11                               american-barber-shop-los-angeles
#> 12                                          rvm-twist-los-angeles
#> 13                              hair-by-electra-blue-sherman-oaks
#> 14                        foxtrot-lash-and-beauty-bar-los-angeles
#> 15 francis-certified-brazilian-blowouts-color-and-fun-los-angeles
#> 16                                  ocean-nail-spa-marina-del-rey
#> 17                               worth-it-salon-spa-los-angeles-6
#> 18                                 cocoaloveshair-redondo-beach-2
#> 19                            the-color-bar-by-diine-montebello-2
#> 20                                  create-hair-studio-montebello
#> # ... with 23 more variables: name <chr>, image_url <chr>,
#> #   is_closed <lgl>, url <chr>, review_count <int>,
#> #   category_aliases <list>, category_titles <list>, rating <dbl>,
#> #   latitude <dbl>, longitude <dbl>, transactions <list>, price <chr>,
#> #   address1 <chr>, address2 <chr>, address3 <chr>, city <chr>,
#> #   zip_code <chr>, state <chr>, country <chr>, display_address <list>,
#> #   phone <chr>, display_phone <chr>, distance_m <dbl>
```
