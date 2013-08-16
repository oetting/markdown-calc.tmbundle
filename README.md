# Markdown Calc

Markdown calc is a TextMate plugin that allows calculation of math statements bedded in markdown code blocks. 

This is heavily inspired by [Calca](http://calca.io), which is awesome. This plugin does a little of what Calca does, but Calca is much more powerful, and importantly does symbol manipulation, so not just simple calculations like this plugin. If you haven't seen calca, go have a look at it.

## Example


If I buy a house at `price = 1,200,000` and a `down payment in pct = 20%` with a interest rate of `interest = 3.7%` the following calculation

    down payment = down payment in pct * price => 240,000.0
    amount to borrow = price - down payment

    years = 30
    terms pr year = 4
    
    n = years * terms pr year
    i = interest / 4
    
    monthly payment = i/(1-(1+i)^-n) * amount to borrow * 
        terms pr year / 12

Shows that my monthly payment will be `monthly payment => 4,426.1336`

## Usage

Write your math in markdown code blocks, that is either inline delimited by ` ` or indented by a tab or four spaces. 

Add `=>` at the end of a statement if you want to output the result (anything after `=>` will be replaced with the result on each re-calculation). 

If the result is an error and there is no `=>` on the line a `!=>` plus the error will be inserted. `!=>` and anything after it will be removed if there is no error. 

Variables are case insensitive, and can contain spaces and any characters (even non ASCII)

You can define functions using the following syntax. 

    define sum(a, b) {
        return a + b
    }
    sum(2, 3) => 5.0


## Notes

Markdown Calc uses [bc]() to perform the calculations. Some simple transformations are performed to the statements to allow

## TODO    

 - Only allow scope to go to 1
 - _ in vars should be escaped
 - make built in functions (sin,cos,tan,pi,sqrt)

