# Activity Reflection

## Coffee Deserts and Oases: Mapping Coffee Shops

Name: Add Your Name Here

Date: TODO

## Instructions

Answer every question below based on what you observed while fixing and
running `src/coffee_maps.R` and playing with the Shiny app. Please be
specific: reference actual values, neighborhoods, columns, or plot output
where relevant. Use fenced code blocks for any code or output you want to
quote. Two to four sentences is usually enough for each response.

---

## Part A: Conceptual Questions (Maps and Debugging)

### Q1. Why `coord_quickmap()`?

Every map in the script uses `coord_quickmap()`. In your own words, what does
it do to the plot, and what could go wrong if you left it out and let
`ggplot()` stretch longitude and latitude to fill the plot window?

Response:

TODO

### Q2. Points, Hexes, and Tiles

You drew the same shops three ways: `geom_point()` (Part 2), `geom_hex()`
(Part 5), and `geom_tile()` (Part 6). Which question does each geom answer
best? When would plain points be a poor choice?

Response:

TODO

### Q3. Debugging Strategy

Pick the bug that took you the longest to fix. What was the error message,
what was actually wrong, and what clue (in the message, the hint, or the
code) finally led you to the fix? Which kind of bug (spelling, capitalization,
punctuation, missing argument) do you think you will spot fastest next time?

Response:

TODO

---

## Part B: Critical Thinking (Deserts and Oases)

### Q4. Defining Deserts and Oases

Using your density map (Part 5) and your zone map (Part 6), describe where the
coffee oases are and where the coffee deserts are. Name at least two oases
and two deserts (use neighborhoods or landmarks) and cite one number from
your output (e.g., from `neighborhood_summary` or `zones %>% count(zone)`).

Response:

TODO

### Q5. Is a Desert Really a Problem?

Compare the desert cells to the landmarks on your zone map. Is every desert
a place where people would want coffee? Which deserts matter most, which
matter least, and what information is NOT in these data that you would want
before deciding?

Response:

TODO

### Q6. Choosing the Rules

We called a cell an "Oasis" at 8 or more shops and a "Desert" at exactly 0,
using cells of about 1 km x 1 km. Those choices were ours, not the data's.
What would happen to the map if the cell size were much larger (say, 5 km),
or if "Oasis" required 20 shops? Could someone use this to make the same data
tell a different story?

Response:

TODO

### Q7. Clusters and Competition

Coffee shops pile up in a few places. Propose two reasons why shops cluster
together instead of spreading out evenly. Then use `chain_type` or `rating`
from the interactive map (Part 7) or the data to note one difference you can
see between an oasis (e.g., Downtown) and a strip or plaza
(e.g., Westgate Plaza or Route 322 Strip).

Response:

TODO

### Q8. Before You Open a Shop

A friend wants to open a new coffee shop and says, "Put it in the biggest
desert!" Give one reason this could be a great idea and one reason it could
be a terrible idea. List two additional datasets that would make the advice
more trustworthy.

Response:

TODO

### Q9. Reading the City Map

Look at your made-up city maps from Part 8. Choose one coffee desert (a red
area in the second map) and describe what is physically there: roads,
buildings, parks, the river, or the highway. Does the city layout help explain
why the shops are missing there, or does it make you want to change your
answer to Q5? Also, what does the city map show that the plain longitude and
latitude maps did not?

Response:

TODO

---

## Part C: The Shiny App

Run the app with `shiny::runApp("shiny_app")` from the activity folder.

### Q10. How Far Is Far?

Set the walking-time slider to 5, 10, and 15 minutes (leave the filters at
their defaults). Record the "Share of map within walking limit" for each
setting. Which landmark is the LAST to become "Served," and what does that
tell you about who has the hardest time getting coffee?

Response:

TODO

### Q11. Quality Deserts

Keep the walking limit at 10 minutes, then raise "Only count shops rated at
least" to 4.5 (or try showing only National chains or only Independents).
How does the served share change? Explain how a place can have shops nearby
and still be a "desert" for someone with certain preferences.

Response:

TODO

(Did you remember to add your name to the top of this document?)
