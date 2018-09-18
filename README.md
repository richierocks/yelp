<!-- README.md is generated from README.Rmd. Please edit that file -->
    #> Warning: package 'dplyr' was built under R version 3.5.1

yelp
====

This R package provides access to the [Yelp Fusion API, version 3](https://www.yelp.com/developers/documentation/v3).

Installation and setup
----------------------

To use this package, you must install it and get an access token for the API.

### Package installation

To install the package, you first need *remotes* installed.

``` r
install.packages("remotes")
```

``` r
remotes::install_github("richierocks/yelp")
```

### Getting the client ID and client secret

To gain access to the API, you have to [register with Yelp](https://www.yelp.com/signup), log in, and [create your own app](https://www.yelp.com/developers/v3/manage_app). This takes 5 to 10 minutes of pointing and clicking. It's reasonably self-explanatory, and there are more details on the [API Authentication](https://www.yelp.com/developers/documentation/v3/authentication) page.

Once you have registered, make a note of your *client ID* and *client secret*.

### Getting and storing an access token

You use the client ID and client secret to get an access token.

``` r
access_token <- get_access_token(client_id, client_secret)
```

This access token can be passed into individual calls to the API, or you can store it so the package will automatically find it. `store_access_token(access_token)` will store it for the R session, or you can use your operating system tools to set a `YELP_ACCESS_TOKEN` environment variable to store it permanently.

### Join the Developer Beta program

Some features such as business match and event search require you to sign up for the Yelp Developer Beta program. You can do this from the [Manage App](https://www.yelp.com/developers/v3/manage_app) page.

### Set your locale

By default, the package assumes that you are in the USA, and uses the locale `en_US`. You can override this for the session using `set_yelp_locale()`, or premanently by setting an environment variable named `YELP_LOCALE`.

Usage
-----

To search for businesses close to a specific location, call `business_search()` with a string giving a search term and either a string describing a location or numbers giving latitude and longitude. The return value is a tibble (since it has a nicer print method for wider data frames) with one business per row.

``` r
suppressPackageStartupMessages(library(dplyr, quiet = TRUE))
```

``` r
library(yelp)
library(dplyr)
salons_in_la <- business_search("beauty salon", "los angeles")
glimpse(salons_in_la)
#> Observations: 20
#> Variables: 25
#> $ id               <chr> "XNcjEN9M2kjChBaJioE3eQ", "yII2VaCD9MnKmNKqEz...
#> $ alias            <chr> "margaritas-beauty-salon-los-angeles-3", "bri...
#> $ name             <chr> "Margarita's Beauty Salon", "Brianna's Beauty...
#> $ rating           <dbl> 3.5, 5.0, 4.5, 5.0, 5.0, 5.0, 4.0, 3.5, 5.0, ...
#> $ review_count     <int> 24, 5, 7, 4, 92, 4, 7, 11, 9, 23, 7, 16, 297,...
#> $ price            <chr> "$", "$", "$$", "$$", "$$", "$$", "$", "$", "...
#> $ image_url        <chr> "https://s3-media2.fl.yelpcdn.com/bphoto/uXL5...
#> $ is_closed        <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL...
#> $ url              <chr> "https://www.yelp.com/biz/margaritas-beauty-s...
#> $ category_aliases <list> ["hair", <"hair", "waxing", "eyelashservice"...
#> $ category_titles  <list> ["Hair Salons", <"Hair Salons", "Waxing", "E...
#> $ latitude         <dbl> 34.03502, 34.08803, 34.04836, 34.09760, 34.06...
#> $ longitude        <dbl> -118.4387, -118.3090, -118.3430, -118.3652, -...
#> $ distance_m       <dbl> 11200.409, 3156.545, 2464.888, 5687.579, 2641...
#> $ transactions     <list> [<>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,...
#> $ address1         <chr> "2403 Sawtelle Blvd", "968 N Western Ave", "4...
#> $ address2         <chr> "", "", "Ste B", "Ste B-200", "Fl 2", "Sola S...
#> $ address3         <chr> "", "", "", "", "", "Ste 102, Studio 5", "", ...
#> $ city             <chr> "Los Angeles", "Los Angeles", "Los Angeles", ...
#> $ zip_code         <chr> "90064", "90029", "90019", "90046", "90005", ...
#> $ state            <chr> "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA...
#> $ country          <chr> "US", "US", "US", "US", "US", "US", "US", "US...
#> $ display_address  <chr> "2403 Sawtelle Blvd, Los Angeles, CA 90064", ...
#> $ phone            <chr> "+13104770119", "+13238484188", "+13239367830...
#> $ display_phone    <chr> "(310) 477-0119", "(323) 848-4188", "(323) 93...
```

The results include the longitude and latitude of each business, so you can use [*ggmap*](https://cran.r-project.org/web/packages/ggmap) to plot their locations.

``` r
library(ggmap)
library(magrittr)
la <- salons_in_la %$%
  c(median(longitude), median(latitude))
la_map <- get_map(la, zoom = 11)
#> Source : https://maps.googleapis.com/maps/api/staticmap?center=34.062317,-118.308265&zoom=11&size=640x640&scale=2&maptype=terrain&language=en-EN
(map_plot_of_salons_in_la <- ggmap(la_map) + 
  geom_point(aes(longitude, latitude), data = salons_in_la)
)
```

![](man/figures/README-ggmap-1.png)

<!--

![Map of Los Angeles, with businesses marked as points.](man/figures/README-ggmap-1.png)
-->
Once you have spotted an interesting business, make a note of the business ID from the `id` column as it is required as an argument for several of the other functions.

``` r
arianna_hair_boutique_id <- salons_in_la %>% 
  filter(name == "Arianna Hair Boutique") %>% 
  pull(id)
```

You can use the business ID with the `business_lookup()` to get more detailed information about that business, including opening hours.

``` r
arianna_hair_boutique_details <- business_lookup(arianna_hair_boutique_id)
glimpse(arianna_hair_boutique_details)
#> Observations: 1
#> Variables: 29
#> $ id                    <chr> "4gV99Gc24G3ZGOwZfwPh4g"
#> $ alias                 <chr> "arianna-hair-boutique-los-angeles"
#> $ name                  <chr> "Arianna Hair Boutique"
#> $ rating                <dbl> 4.5
#> $ review_count          <int> 297
#> $ price                 <chr> "$$"
#> $ image_url             <chr> "https://s3-media1.fl.yelpcdn.com/bphoto...
#> $ is_closed             <lgl> FALSE
#> $ url                   <chr> "https://www.yelp.com/biz/arianna-hair-b...
#> $ category_aliases      <list> [<"hair", "eyelashservice", "othersalon...
#> $ category_titles       <list> [<"Hair Salons", "Eyelash Service", "Na...
#> $ latitude              <dbl> 34.0619
#> $ longitude             <dbl> -118.2939
#> $ distance_m            <dbl> NA
#> $ transactions          <list> [<>]
#> $ address1              <chr> "3287 Wilshire Blvd"
#> $ address2              <chr> ""
#> $ address3              <chr> ""
#> $ city                  <chr> "Los Angeles"
#> $ zip_code              <chr> "90010"
#> $ state                 <chr> "CA"
#> $ country               <chr> "US"
#> $ display_address       <chr> "3287 Wilshire Blvd, Los Angeles, CA 90010"
#> $ phone                 <chr> "+12137360481"
#> $ display_phone         <chr> "(213) 736-0481"
#> $ photos                <list> [["https://s3-media1.fl.yelpcdn.com/bph...
#> $ is_claimed            <lgl> TRUE
#> $ is_permanently_closed <lgl> FALSE
#> $ opening_hours         <list> [<# A tibble: 7 x 4,   start_day start_...
arianna_hair_boutique_details$opening_hours
#> [[1]]
#> # A tibble: 7 x 4
#>   start_day start_time end_day   end_time
#>   <chr>     <chr>      <chr>     <chr>   
#> 1 Monday    1000       Monday    2200    
#> 2 Tuesday   1000       Tuesday   2200    
#> 3 Wednesday 1000       Wednesday 2200    
#> 4 Thursday  1000       Thursday  2200    
#> 5 Friday    1000       Friday    2200    
#> 6 Saturday  1000       Saturday  1900    
#> 7 Sunday    1200       Sunday    1800
```

You can also use `reviews()` to get reviews of that business.

``` r
arianna_hair_boutique_reviews <- reviews(arianna_hair_boutique_id)
glimpse(arianna_hair_boutique_reviews)
#> Observations: 3
#> Variables: 7
#> $ id             <chr> "tSpuDVsdpBbpw96eNe6EDw", "rtuIb6e1dtTq-wzY4pst...
#> $ rating         <int> 5, 5, 5
#> $ text           <chr> "I love this place. Not only is it walking dist...
#> $ time_created   <chr> "2018-08-07 22:48:44", "2018-08-06 18:54:27", "...
#> $ url            <chr> "https://www.yelp.com/biz/arianna-hair-boutique...
#> $ user_image_url <chr> "https://s3-media4.fl.yelpcdn.com/photo/4EA-Nlq...
#> $ user_name      <chr> "Mel D.", "Jess M.", "Nicole L."
```

These can be used with the [*tidytext*](https://cran.r-project.org/web/packages/tidytext) package to perform a sentiment analysis.

``` r
library(tidytext)
(arianna_hair_boutique_sentiments <- arianna_hair_boutique_reviews %>% 
  select(id, rating, text) %>% 
  unnest_tokens(word, text) %>% 
  anti_join(get_stopwords(), by = "word") %>% 
  inner_join(get_sentiments("bing"))
)
#> Joining, by = "word"
#> # A tibble: 8 x 4
#>   id                     rating word         sentiment
#>   <chr>                   <int> <chr>        <chr>    
#> 1 tSpuDVsdpBbpw96eNe6EDw      5 love         positive 
#> 2 tSpuDVsdpBbpw96eNe6EDw      5 awesome      positive 
#> 3 tSpuDVsdpBbpw96eNe6EDw      5 great        positive 
#> 4 rtuIb6e1dtTq-wzY4pstjg      5 disappointed negative 
#> 5 rtuIb6e1dtTq-wzY4pstjg      5 right        positive 
#> 6 0N02C-h3XHFU9pra0BOYNg      5 hail         positive 
#> 7 0N02C-h3XHFU9pra0BOYNg      5 wonder       positive 
#> 8 0N02C-h3XHFU9pra0BOYNg      5 magic        positive
```

There are some other functions with more niche usage.

-   `autocomplete()` takes a search term, and returns some related search terms that Yelp understands.
-   `business_match()` provides a more targetted search for a business, when you know its name and rough address.
-   `event_search()` lets you search for events that are happening near a location.
-   `event_lookup()` returns details for a specific event given its Yelp ID.
-   `featured_event()` returns the Yelp-curated featured event for a location.
-   `food_delivery_search()` lets you find businesses that will deliver food to a given location.
-   `categories()` provides more information on the search category aliases.
-   `phone_search()` lets you search for a business by phone number.
