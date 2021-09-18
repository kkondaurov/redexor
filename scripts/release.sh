#!/bin/bash
MIX_ENV=prod mix deps.get --only prod \
&& MIX_ENV=prod mix compile \
&& cd apps/redexor_web/ && MIX_ENV=prod mix assets.deploy --force && cd ../.. \
&& MIX_ENV=prod mix release --overwrite \
&& cd apps/redexor_web/ && MIX_ENV=prod mix phx.digest.clean --all && cd ../.. \
&& _build/prod/rel/redexor/bin/redexor eval "Redexor.Release.seed"