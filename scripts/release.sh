#!/bin/bash
MIX_ENV=prod mix deps.get --only prod \
&& MIX_ENV=prod mix compile \
&& MIX_ENV=prod mix assets.deploy --force \
&& MIX_ENV=prod mix release --overwrite \
&& MIX_ENV=prod mix phx.digest.clean --all \
&& _build/prod/rel/redexor/bin/redexor eval "Redexor.Release.seed"