<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis Build Status](https://travis-ci.org/richierocks/yelp.svg?branch=master)](https://travis-ci.org/richierocks/yelp) [![Build status](https://ci.appveyor.com/api/projects/status/2jv8csk42679foc4?svg=true)](https://ci.appveyor.com/project/richierocks/yelp)

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

By default, the package assumes that you are in the USA, and uses the locale `en_US`. You can override this for the session using `set_yelp_locale()`, or permanently by setting an environment variable named `YELP_LOCALE`.

Usage
-----

To search for businesses close to a specific location, call `business_search()` with a string giving a search term and either a string describing a location or numbers giving latitude and longitude. The return value is a tibble (since it has a nicer print method for wider data frames) with one business per row.

``` r
library(yelp)
library(dplyr)
salons_in_la <- business_search("beauty salon", "los angeles")
glimpse(salons_in_la)
#> Observations: 20
#> Variables: 25
#> $ business_id      <chr> "whbjQu04BvffC11CZfGEzA", "yII2VaCD9MnKmNKqEz...
#> $ alias            <chr> "magys-beauty-salon-los-angeles-2", "briannas...
#> $ name             <chr> "Magys Beauty Salon", "Brianna's Beauty Salon...
#> $ rating           <ord> 4.5, 5, 4, 3.5, 5, 5, 4.5, 4.5, 3.5, 4, 5, 5,...
#> $ review_count     <int> 8, 5, 7, 12, 93, 48, 7, 316, 23, 16, 8, 24, 3...
#> $ price            <chr> "$$", "$", "$", "$", "$$", "$$", "$$", "$$", ...
#> $ image_url        <chr> "https://s3-media4.fl.yelpcdn.com/bphoto/ZHK2...
#> $ is_closed        <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL...
#> $ url              <chr> "https://www.yelp.com/biz/magys-beauty-salon-...
#> $ category_aliases <list> [<"hair", "hairremoval", "personalcare">, <"...
#> $ category_titles  <list> [<"Hair Salons", "Hair Removal", "Personal C...
#> $ latitude         <dbl> 34.21657, 34.08803, 34.09053, 34.03263, 34.06...
#> $ longitude        <dbl> -118.3879, -118.3090, -118.3081, -118.1536, -...
#> $ distance_m       <dbl> 18310.313, 3156.545, 3443.914, 15757.854, 264...
#> $ transactions     <list> [<>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,...
#> $ address1         <chr> "8031 Lankershim Blvd", "968 N Western Ave", ...
#> $ address2         <chr> "", "", "", "", "Fl 2", "", "", "", "", "", "...
#> $ address3         <chr> "", "", "", "", "", "", "", "", "", "", "", "...
#> $ city             <chr> "Los Angeles", "Los Angeles", "Los Angeles", ...
#> $ zip_code         <chr> "91605", "90029", "90029", "90022", "90005", ...
#> $ state            <chr> "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA...
#> $ country          <chr> "US", "US", "US", "US", "US", "US", "US", "US...
#> $ display_address  <chr> "8031 Lankershim Blvd, Los Angeles, CA 91605"...
#> $ phone            <chr> "+18187436944", "+13238484188", "+13234665829...
#> $ display_phone    <chr> "(818) 743-6944", "(323) 848-4188", "(323) 46...
```

The results include the longitude and latitude of each business, so you can use [*ggmap*](https://cran.r-project.org/web/packages/ggmap) to plot their locations.

``` r
library(ggmap)
library(magrittr)
la <- salons_in_la %$%
  c(median(longitude), median(latitude))
la_map <- get_map(la, zoom = 11)
#> Source : https://maps.googleapis.com/maps/api/staticmap?center=34.057281,-118.309928&zoom=11&size=640x640&scale=2&maptype=terrain&language=en-EN
(map_plot_of_salons_in_la <- ggmap(la_map) + 
  geom_point(aes(longitude, latitude), data = salons_in_la)
)
```

![](man/figures/README-ggmap-1.png)

<!--

![Map of Los Angeles, with businesses marked as points.](man/figures/README-ggmap-1.png)
-->
You can use standard `dplyr` tools to filter for businesses that are interesting to you.

``` r
five_stars_and_cheap <- salons_in_la %>% 
  filter(rating == 5, price == "$") 
```

`business_lookup()` gives you more detailed information about businesses, including opening hours. It costs 1 API call per business, so do your filtering before you call it.

``` r
five_stars_and_cheap_details <- business_lookup(five_stars_and_cheap)
glimpse(five_stars_and_cheap_details)
#> Observations: 3
#> Variables: 29
#> $ business_id           <chr> "yII2VaCD9MnKmNKqEzOY0w", "rCxfVI-UQGzgU...
#> $ alias                 <chr> "briannas-beauty-salon-los-angeles-2", "...
#> $ name                  <chr> "Brianna's Beauty Salon", "Yuritzi's Bea...
#> $ rating                <ord> 5, 5, 5
#> $ review_count          <int> 5, 24, 8
#> $ price                 <chr> "$", "$", "$"
#> $ image_url             <chr> "https://s3-media4.fl.yelpcdn.com/bphoto...
#> $ is_closed             <lgl> FALSE, FALSE, FALSE
#> $ url                   <chr> "https://www.yelp.com/biz/briannas-beaut...
#> $ category_aliases      <list> [<"hair", "waxing", "eyelashservice">, ...
#> $ category_titles       <list> [<"Hair Salons", "Waxing", "Eyelash Ser...
#> $ latitude              <dbl> 34.08803, 34.11381, 34.03223
#> $ longitude             <dbl> -118.3090, -118.2543, -118.2997
#> $ distance_m            <dbl> NA, NA, NA
#> $ transactions          <list> [<>, <>, <>]
#> $ address1              <chr> "968 N Western Ave", "3254 Atwater Ave",...
#> $ address2              <chr> "", "", ""
#> $ address3              <chr> "", "", ""
#> $ city                  <chr> "Los Angeles", "Los Angeles", "Los Angeles"
#> $ zip_code              <chr> "90029", "90039", "90007"
#> $ state                 <chr> "CA", "CA", "CA"
#> $ country               <chr> "US", "US", "US"
#> $ display_address       <chr> "968 N Western Ave, Los Angeles, CA 9002...
#> $ phone                 <chr> "+13238484188", "+13236615084", "+132373...
#> $ display_phone         <chr> "(323) 848-4188", "(323) 661-5084", "(32...
#> $ photos                <list> [["https://s3-media4.fl.yelpcdn.com/bph...
#> $ is_claimed            <lgl> TRUE, TRUE, TRUE
#> $ is_permanently_closed <lgl> FALSE, FALSE, FALSE
#> $ opening_hours         <list> [<# A tibble: 7 x 4,   start_day start_...
five_stars_and_cheap_details$opening_hours
#> [[1]]
#> # A tibble: 7 x 4
#>   start_day start_time end_day   end_time
#>   <chr>     <chr>      <chr>     <chr>   
#> 1 Monday    0900       Monday    2100    
#> 2 Tuesday   0900       Tuesday   2100    
#> 3 Wednesday 0900       Wednesday 2100    
#> 4 Thursday  0900       Thursday  2100    
#> 5 Friday    0900       Friday    2100    
#> 6 Saturday  0900       Saturday  2100    
#> 7 Sunday    0900       Sunday    2100    
#> 
#> [[2]]
#> # A tibble: 6 x 4
#>   start_day start_time end_day   end_time
#>   <chr>     <chr>      <chr>     <chr>   
#> 1 Monday    0930       Monday    1830    
#> 2 Tuesday   0930       Tuesday   1830    
#> 3 Wednesday 0930       Wednesday 1830    
#> 4 Thursday  0930       Thursday  1830    
#> 5 Friday    0930       Friday    1830    
#> 6 Saturday  0830       Saturday  1830    
#> 
#> [[3]]
#> # A tibble: 7 x 4
#>   start_day start_time end_day   end_time
#>   <chr>     <chr>      <chr>     <chr>   
#> 1 Monday    1000       Monday    1900    
#> 2 Tuesday   1000       Tuesday   1900    
#> 3 Wednesday 1000       Wednesday 1900    
#> 4 Thursday  1000       Thursday  1900    
#> 5 Friday    1000       Friday    1900    
#> 6 Saturday  0900       Saturday  1900    
#> 7 Sunday    1000       Sunday    1800
```

You can also use `reviews()` to get reviews of the businesses. Again, it costs 1 API call per business. Also, you are limited to 3 reviews per business, and the text of each is truncated. This is an API limitation, not a problem with this R package.

``` r
five_stars_and_cheap_reviews <- reviews(five_stars_and_cheap)
glimpse(five_stars_and_cheap_reviews)
#> Observations: 9
#> Variables: 8
#> $ business_id    <chr> "yII2VaCD9MnKmNKqEzOY0w", "yII2VaCD9MnKmNKqEzOY...
#> $ review_id      <chr> "XhjsOuc2tAJ21Lh3ypsJIQ", "eSPWyeP6Tv5Whj0hvdNv...
#> $ rating         <ord> 4, 5, 5, 5, 5, 5, 5, 5, 5
#> $ text           <chr> "Fast & quick. If you are coming for a touch up...
#> $ time_created   <chr> "2018-09-03 17:53:08", "2017-10-20 13:10:42", "...
#> $ url            <chr> "https://www.yelp.com/biz/briannas-beauty-salon...
#> $ user_image_url <chr> "https://s3-media3.fl.yelpcdn.com/photo/BPZueyJ...
#> $ user_name      <chr> "Rida Q.", "Sidney T.", "Roy S.", "Patrick B.",...
```

In theory, these can be used with the [*tidytext*](https://cran.r-project.org/web/packages/tidytext) package to perform a sentiment analysis, though the limited amount of text is a problem.

``` r
library(tidytext)
(five_stars_and_cheap_sentiments <- five_stars_and_cheap_reviews %>% 
  select(business_id, review_id, rating, text) %>% 
  unnest_tokens(word, text) %>% 
  anti_join(get_stopwords(), by = "word") %>% 
  inner_join(get_sentiments("bing"))
)
#> Joining, by = "word"
#> # A tibble: 30 x 5
#>    business_id           review_id             rating word       sentiment
#>    <chr>                 <chr>                 <ord>  <chr>      <chr>    
#>  1 yII2VaCD9MnKmNKqEzOY… XhjsOuc2tAJ21Lh3ypsJ… 4      fast       positive 
#>  2 yII2VaCD9MnKmNKqEzOY… XhjsOuc2tAJ21Lh3ypsJ… 4      clean      positive 
#>  3 yII2VaCD9MnKmNKqEzOY… XhjsOuc2tAJ21Lh3ypsJ… 4      affordable positive 
#>  4 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      recommend… positive 
#>  5 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      impressed  positive 
#>  6 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      amazing    positive 
#>  7 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      work       positive 
#>  8 yII2VaCD9MnKmNKqEzOY… I31QLakCUD999rTygBTF… 5      work       positive 
#>  9 yII2VaCD9MnKmNKqEzOY… I31QLakCUD999rTygBTF… 5      like       positive 
#> 10 rCxfVI-UQGzgUPkJDiC5… xIWyHJXOPRmDW29pYA68… 5      nice       positive 
#> # ... with 20 more rows
```

Yelp also provide information on events. Call `event_search()` to see them.

``` r
events_in_la <- event_search("los angeles")
glimpse(events_in_la)
#> Observations: 50
#> Variables: 28
#> $ event_id         <chr> "los-angeles-3rd-annual-say-no-bullying-festi...
#> $ name             <chr> "3rd Annual Say NO Bullying Festival", "A Tas...
#> $ category         <chr> "festivals-fairs", "food-and-drink", "food-an...
#> $ description      <chr> "Come one! Come ALL! 3rd Annual Say NO Bullyi...
#> $ is_free          <lgl> TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS...
#> $ cost             <dbl> NA, 55, 75, NA, 3, 6, NA, 20, 26, 21, 26, 30,...
#> $ cost_max         <dbl> NA, NA, 100, NA, 12, 14, NA, 50, 1895, 35, 40...
#> $ business_id      <chr> "griffith-park-los-angeles-3", "old-town-monr...
#> $ event_site_url   <chr> "https://www.yelp.com/events/los-angeles-3rd-...
#> $ image_url        <chr> "https://s3-media2.fl.yelpcdn.com/ephoto/1WEI...
#> $ tickets_url      <chr> "http://www.saynobullying.org", "https://www....
#> $ interested_count <int> 3, 13, 4, 2, 16, 5, 17, 11, 81, 3, 1, 7, 35, ...
#> $ attending_count  <int> 3, 6, 3, 2, 17, 1, 20, 2, 63, 3, 2, 5, 24, 33...
#> $ time_start       <chr> "2018-10-14 20:00", "2018-10-22 00:00", "2018...
#> $ time_end         <chr> "2018-10-14 23:00", "2018-10-22 03:00", "", "...
#> $ is_canceled      <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL...
#> $ is_official      <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL...
#> $ latitude         <dbl> 34.13662, 34.14807, 33.98179, 33.84865, 34.04...
#> $ longitude        <dbl> -118.2944, -118.0010, -118.3924, -118.0079, -...
#> $ address1         <chr> "4730 Crystal Springs Dr", "400 S Myrtle Ave"...
#> $ address2         <chr> "", "", "", "", "", "", "", "", "", "", "", "...
#> $ address3         <chr> "", "", "", "", "", "", "", "", "", "", "", "...
#> $ city             <chr> "Los Angeles", "Monrovia", "Culver City", "Bu...
#> $ zip_code         <chr> "90027", "91016", "90230", "90620", "91768", ...
#> $ state            <chr> "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA...
#> $ country          <chr> "US", "US", "US", "US", "US", "US", "US", "US...
#> $ display_address  <chr> "4730 Crystal Springs Dr, Los Angeles, CA 900...
#> $ cross_streets    <chr> "", "", "", "", "", "", "", "", "", "", "", "...
```

There are some other functions with more niche usage.

-   `autocomplete()` takes a search term, and returns some related search terms that Yelp understands.
-   `business_match()` provides a more targetted search for a business, when you know its name and rough address.
-   `event_lookup()` returns details for a specific event given its Yelp ID.
-   `featured_event()` returns the Yelp-curated featured event for a location.
-   `food_delivery_search()` lets you find businesses that will deliver food to a given location.
-   `categories()` provides more information on the search category aliases.
-   `phone_search()` lets you search for a business by phone number.
