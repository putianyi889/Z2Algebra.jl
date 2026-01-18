# Linear Algebra Support
✅ = fully supported
❎ = fall back
❌ = not supported
❔ = not tested

## Constructors

|Method|Status|
|:-:|:-:|
|`copytrito!`|❔|
|`triu!`|❔|
|`tril!`|❔|
|`triu`|❔|
|`tril`|❔|

## Arithmetic

### Broadcast

### Addition

|Operation|Status|
|:-:|:-:|
|`mat + mat`|✅|

### Multiplication

|Operation|Status|
|:-:|:-:|
|`mat * mat`|✅|
|`mat * transmat`|❎|
|`mat * rowvec`|❎|
|`mat * colvec`|❎|
|`transmat * mat`|❎|
|`transmat * rowvec`|❎|
|`transmat * colvec`|❎|
|`rowvec ⋅ rowvec`|❔|
|`rowvec ⋅ colvec`|❔|
|`colvec ⋅ rowvec`|❔|

### Division
