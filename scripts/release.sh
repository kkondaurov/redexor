#!/bin/bash
MIX_ENV=prod mix deps.get --only prod \
&& MIX_ENV=prod mix compile \
&& cd apps/restbench_web/ && MIX_ENV=prod mix assets.deploy --force && cd ../.. \
&& MIX_ENV=prod mix release --overwrite \
&& cd apps/restbench_web/ && MIX_ENV=prod mix phx.digest.clean --all && cd ../.. \
&& _build/prod/rel/restbench/bin/restbench eval "Restbench.Release.seed"