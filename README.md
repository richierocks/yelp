<!-- README.md is generated from README.Rmd. Please edit that file -->
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
#> $ business_id      <chr> "whbjQu04BvffC11CZfGEzA", "XNcjEN9M2kjChBaJio...
#> $ alias            <chr> "magys-beauty-salon-los-angeles-2", "margarit...
#> $ name             <chr> "Magys Beauty Salon", "Margarita's Beauty Sal...
#> $ rating           <ord> 4.5, 3.5, 5, 5, 4.5, 5, 5, 5, 4, 3.5, 5, 5, 4...
#> $ review_count     <int> 8, 23, 5, 48, 7, 4, 92, 4, 7, 11, 9, 9, 7, 24...
#> $ price            <chr> "$$", "$", "$", "$$", "$$", "$$", "$$", "$$",...
#> $ image_url        <chr> "https://s3-media4.fl.yelpcdn.com/bphoto/ZHK2...
#> $ is_closed        <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL...
#> $ url              <chr> "https://www.yelp.com/biz/magys-beauty-salon-...
#> $ category_aliases <list> [<"hair", "hairremoval", "personalcare">, "h...
#> $ category_titles  <list> [<"Hair Salons", "Hair Removal", "Personal C...
#> $ latitude         <dbl> 34.21657, 34.03502, 34.08803, 34.04309, 34.04...
#> $ longitude        <dbl> -118.3879, -118.4387, -118.3090, -118.4577, -...
#> $ distance_m       <dbl> 18310.313, 11200.409, 3156.545, 11852.204, 24...
#> $ transactions     <list> [<>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,...
#> $ address1         <chr> "8031 Lankershim Blvd", "2403 Sawtelle Blvd",...
#> $ address2         <chr> "", "", "", "", "Ste B", "Ste B-200", "Fl 2",...
#> $ address3         <chr> "", "", "", "", "", "", "", "Ste 102, Studio ...
#> $ city             <chr> "Los Angeles", "Los Angeles", "Los Angeles", ...
#> $ zip_code         <chr> "91605", "90064", "90029", "90025", "90019", ...
#> $ state            <chr> "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA...
#> $ country          <chr> "US", "US", "US", "US", "US", "US", "US", "US...
#> $ display_address  <chr> "8031 Lankershim Blvd, Los Angeles, CA 91605"...
#> $ phone            <chr> "+18187436944", "+13104770119", "+13238484188...
#> $ display_phone    <chr> "(818) 743-6944", "(310) 477-0119", "(323) 84...
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
#> $ business_id           <chr> "yII2VaCD9MnKmNKqEzOY0w", "NMkt-I3OhC_bR...
#> $ alias                 <chr> "briannas-beauty-salon-los-angeles-2", "...
#> $ name                  <chr> "Brianna's Beauty Salon", "Hair by Laure...
#> $ rating                <ord> 5, 5, 5
#> $ review_count          <int> 5, 9, 23
#> $ price                 <chr> "$", "$", "$"
#> $ image_url             <chr> "https://s3-media2.fl.yelpcdn.com/bphoto...
#> $ is_closed             <lgl> FALSE, FALSE, FALSE
#> $ url                   <chr> "https://www.yelp.com/biz/briannas-beaut...
#> $ category_aliases      <list> [<"hair", "waxing", "eyelashservice">, ...
#> $ category_titles       <list> [<"Hair Salons", "Waxing", "Eyelash Ser...
#> $ latitude              <dbl> 34.08803, 33.95879, 34.11381
#> $ longitude             <dbl> -118.3090, -118.3108, -118.2543
#> $ distance_m            <dbl> NA, NA, NA
#> $ transactions          <list> [<>, <>, <>]
#> $ address1              <chr> "968 N Western Ave", "1848 W 87th St", "...
#> $ address2              <chr> "", "", ""
#> $ address3              <chr> "", "", ""
#> $ city                  <chr> "Los Angeles", "Los Angeles", "Los Angeles"
#> $ zip_code              <chr> "90029", "90047", "90039"
#> $ state                 <chr> "CA", "CA", "CA"
#> $ country               <chr> "US", "US", "US"
#> $ display_address       <chr> "968 N Western Ave, Los Angeles, CA 9002...
#> $ phone                 <chr> "+13238484188", "+12132558085", "+132366...
#> $ display_phone         <chr> "(323) 848-4188", "(213) 255-8085", "(32...
#> $ photos                <list> [["https://s3-media2.fl.yelpcdn.com/bph...
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
#> # A tibble: 7 x 4
#>   start_day start_time end_day   end_time
#>   <chr>     <chr>      <chr>     <chr>   
#> 1 Monday    0900       Monday    1900    
#> 2 Tuesday   1800       Tuesday   2200    
#> 3 Wednesday 1800       Wednesday 2200    
#> 4 Thursday  1800       Thursday  2200    
#> 5 Friday    1800       Friday    2200    
#> 6 Saturday  1800       Saturday  2200    
#> 7 Sunday    0900       Sunday    1900    
#> 
#> [[3]]
#> # A tibble: 6 x 4
#>   start_day start_time end_day   end_time
#>   <chr>     <chr>      <chr>     <chr>   
#> 1 Monday    0930       Monday    1830    
#> 2 Tuesday   0930       Tuesday   1830    
#> 3 Wednesday 0930       Wednesday 1830    
#> 4 Thursday  0930       Thursday  1830    
#> 5 Friday    0930       Friday    1830    
#> 6 Saturday  0830       Saturday  1830
```

You can also use `reviews()` to get reviews of the businesses. Again, it costs 1 API call per business. Also, you are limited to 3 reviews per business, and the text of each is truncated. This is an API limitation, not a problem with this R package.

``` r
five_stars_and_cheap_reviews <- reviews(five_stars_and_cheap)
glimpse(five_stars_and_cheap_reviews)
#> Observations: 9
#> Variables: 8
#> $ business_id    <chr> "yII2VaCD9MnKmNKqEzOY0w", "yII2VaCD9MnKmNKqEzOY...
#> $ review_id      <chr> "I31QLakCUD999rTygBTFDA", "XhjsOuc2tAJ21Lh3ypsJ...
#> $ rating         <ord> 5, 4, 5, 5, 5, 5, 5, 5, 5
#> $ text           <chr> "their work is so detailed and they take their ...
#> $ time_created   <chr> "2018-04-27 19:41:09", "2018-09-03 17:53:08", "...
#> $ url            <chr> "https://www.yelp.com/biz/briannas-beauty-salon...
#> $ user_image_url <chr> "https://s3-media1.fl.yelpcdn.com/photo/bkpdbSB...
#> $ user_name      <chr> "Roy S.", "Rida Q.", "Sidney T.", "Keni G.", "B...
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
#> # A tibble: 20 x 5
#>    business_id           review_id             rating word       sentiment
#>    <chr>                 <chr>                 <ord>  <chr>      <chr>    
#>  1 yII2VaCD9MnKmNKqEzOY… I31QLakCUD999rTygBTF… 5      work       positive 
#>  2 yII2VaCD9MnKmNKqEzOY… I31QLakCUD999rTygBTF… 5      like       positive 
#>  3 yII2VaCD9MnKmNKqEzOY… XhjsOuc2tAJ21Lh3ypsJ… 4      fast       positive 
#>  4 yII2VaCD9MnKmNKqEzOY… XhjsOuc2tAJ21Lh3ypsJ… 4      clean      positive 
#>  5 yII2VaCD9MnKmNKqEzOY… XhjsOuc2tAJ21Lh3ypsJ… 4      affordable positive 
#>  6 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      recommend… positive 
#>  7 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      impressed  positive 
#>  8 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      amazing    positive 
#>  9 yII2VaCD9MnKmNKqEzOY… eSPWyeP6Tv5Whj0hvdNv… 5      work       positive 
#> 10 NMkt-I3OhC_bRG-krPXp… QlYjqYsEQELBJmoNWEqt… 5      promised   positive 
#> 11 NMkt-I3OhC_bRG-krPXp… QlYjqYsEQELBJmoNWEqt… 5      happy      positive 
#> 12 NMkt-I3OhC_bRG-krPXp… mPy1Uan2-xxh8AXSv8Bt… 5      best       positive 
#> 13 NMkt-I3OhC_bRG-krPXp… 3itCHdIXCnemcPtC9I67… 5      great      positive 
#> 14 NMkt-I3OhC_bRG-krPXp… 3itCHdIXCnemcPtC9I67… 5      polite     positive 
#> 15 NMkt-I3OhC_bRG-krPXp… 3itCHdIXCnemcPtC9I67… 5      nice       positive 
#> 16 NMkt-I3OhC_bRG-krPXp… 3itCHdIXCnemcPtC9I67… 5      loved      positive 
#> 17 rCxfVI-UQGzgUPkJDiC5… yGRC3iVbIXjYQ855ujm8… 5      love       positive 
#> 18 rCxfVI-UQGzgUPkJDiC5… yGRC3iVbIXjYQ855ujm8… 5      sweet      positive 
#> 19 rCxfVI-UQGzgUPkJDiC5… vBtH60Bd0t2QHsesPSPT… 5      amazing    positive 
#> 20 rCxfVI-UQGzgUPkJDiC5… vBtH60Bd0t2QHsesPSPT… 5      great      positive
```

Yelp also provide information on events. Call `event_search()` to see them.

``` r
events_in_la <- event_search("los angeles")
glimpse(events_in_la)
#> Observations: 50
#> Variables: 28
#> $ event_id         <chr> "glendale-street-food-cinema-2018", "anaheim-...
#> $ name             <chr> "Street Food Cinema 2018", "OC Auto Show", "1...
#> $ category         <chr> "film", "other", "festivals-fairs", "festival...
#> $ description      <chr> "It's more than just a movie. Street Food Cin...
#> $ is_free          <lgl> FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALS...
#> $ cost             <dbl> 6.0, 0.0, NA, NA, NA, 45.0, 50.0, 25.0, 80.0,...
#> $ cost_max         <dbl> 175, 12, NA, NA, NA, 80, 90, NA, 450, 12, NA,...
#> $ business_id      <chr> "street-food-cinema-glendale-4", "anaheim-con...
#> $ event_site_url   <chr> "https://www.yelp.com/events/glendale-street-...
#> $ image_url        <chr> "https://s3-media3.fl.yelpcdn.com/ephoto/tVQF...
#> $ tickets_url      <chr> "http://www.streetfoodcinema.com/pricing/los-...
#> $ interested_count <int> 1931, 3, 1, 3, 2, 15, 0, 3, 1, 1, 2, 2, 1, 1,...
#> $ attending_count  <int> 1582, 5, 3, 3, 1, 4, 2, 2, 1, 2, 6, 3, 1, 1, ...
#> $ time_start       <chr> "2018-09-15 01:00", "2018-10-04 23:00", "2018...
#> $ time_end         <chr> "2018-10-14 05:00", "2018-10-08 02:00", "2018...
#> $ is_canceled      <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL...
#> $ is_official      <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL...
#> $ latitude         <dbl> 34.14328, 33.80239, 34.13962, 34.03367, 33.75...
#> $ longitude        <dbl> -118.2531, -117.9198, -118.2149, -118.2410, -...
#> $ address1         <chr> "201 E Colorado St", "800 W Katella Ave", "22...
#> $ address2         <chr> "Glendale Central Park", "", "", "", "", "", ...
#> $ address3         <chr> "", "", "", "", "", "", "", "", "", "", "", "...
#> $ city             <chr> "Glendale", "Anaheim", "Los Angeles", "Los An...
#> $ zip_code         <chr> "91205", "92802", "90041", "90021", "90803", ...
#> $ state            <chr> "CA", "CA", "CA", "CA", "CA", "CA", "CA", "CA...
#> $ country          <chr> "US", "US", "US", "US", "US", "US", "US", "US...
#> $ display_address  <chr> "201 E Colorado St, Glendale Central Park, Gl...
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
