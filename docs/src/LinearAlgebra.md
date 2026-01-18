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

## Broadcast

## Arithmetic

|Operation|Status|
|:-:|:-:|
|`mat + mat`|✅|
|`mat - mat`|✅|
|`-mat`|✅|
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
