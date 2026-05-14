# Compatibility fixes

## Scope

This document records compatibility fixes relevant to the Stage2 HCTSA pipeline. These are compatibility/path-level fixes, not analysis-strategy changes.

## SP_Summaries / findpeaks path-level fix

`SP_Summaries` calls MATLAB's `findpeaks` when characterizing spectral peaks.

Chronux also has a `findpeaks`, so the pipeline calls `force_findpeaks_matlab()` immediately before `TS_Compute`.

Representative logs showed:

```text
which_findpeaks_after_force=/usr/local/matlab/r2023a/toolbox/signal/signal/findpeaks.m
```

Interpretation:

- This is a compatibility/path-level fix.
- This is not a feature definition change.
- This is not an analysis strategy change.

## MF_steps_ahead R2023a compatibility fix

HCTSA commit:

```text
763d5ecb Fix MF_steps_ahead predict compatibility (iddata) on R2023a
```

Patch:

```matlab
z = iddata(yTest.y, [], 1);
yhat = predict(m, z, steps(i));
yp = yhat.OutputData;
```

Interpretation:

- This is a MATLAB R2023a / System Identification Toolbox compatibility fix.
- This is not a feature definition change.
- This is not an analysis strategy change.

## Patch copies included in this repository

```text
ops/hctsa/patches/MF_steps_ahead.m
ops/hctsa/patches/NL_TISEAN_fnn.m
```
