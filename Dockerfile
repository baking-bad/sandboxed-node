FROM alpine:3.12
WORKDIR /tezos
RUN wget "https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh" \
  && export OSTYPE=linux \
  && sed '/SAPLING_SPROUT_GROTH16_NAME/d; /progress/d; /retry-connrefused/d' fetch-params.sh | sh \
  && rm fetch-params.sh
ARG TAG
RUN wget "https://github.com/serokell/tezos-packaging/releases/download/$TAG/tezos-node" \
  && chmod +x tezos-node \
  && ./tezos-node config init \
    --data-dir /tezos/sandbox \
    --network sandbox \
    --expected-pow 0.0 \
    --connections 0 \
    --rpc-addr 0.0.0.0:8732 \
  && ./tezos-node identity generate "0.0" \
    --data-dir /tezos/sandbox \
  && echo "{ \"genesis_pubkey\": \"edpkuSLWfVU1Vq7Jg9FucPyKmma6otcMHac9zG4oU1KMHSTBpJuGQ2\" }" > /tezos/sandbox/sandbox.json
ENTRYPOINT ["/tezos/tezos-node", "run", \
    "-vv", \
    "--data-dir=/tezos/sandbox", \
    "--synchronisation-threshold=0", \
    "--sandbox=/tezos/sandbox/sandbox.json"]