FROM alpine:3.12
WORKDIR /tezos
RUN wget "https://raw.githubusercontent.com/zcash/zcash/master/zcutil/fetch-params.sh" \
  && export OSTYPE=linux \
  && sed '/SAPLING_SPROUT_GROTH16_NAME/d; /progress/d; /retry-connrefused/d' fetch-params.sh | sh \
  && rm fetch-params.sh
ARG TARGETPLATFORM
ARG TAG
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then EXEC_NAME="tezos-node-arm64"; else EXEC_NAME="tezos-node"; fi \
  && wget "https://github.com/serokell/tezos-packaging/releases/download/$TAG/$EXEC_NAME" -O "tezos-node" \
  && chmod +x tezos-node
#RUN ./tezos-node identity generate "0.0" --data-dir /tezos/sandbox
COPY ./*.json /tezos/sandbox/
ENTRYPOINT ["/tezos/tezos-node", "run", \
    "-vv", \
    "--data-dir=/tezos/sandbox", \
    "--synchronisation-threshold=0", \
    "--sandbox=/tezos/sandbox/sandbox.json", \
    "--allow-all-rpc=0.0.0.0"]