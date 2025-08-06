FROM alpine:3.19
WORKDIR /tezos
RUN wget "https://raw.githubusercontent.com/zcash/zcash/v5.6.0/zcutil/fetch-params.sh" \
  && export OSTYPE=linux \
  && sed '/SAPLING_SPROUT_GROTH16_NAME/d; /progress/d; /retry-connrefused/d' fetch-params.sh | sh \
  && rm fetch-params.sh

# `fetch-params.sh` is not available since v5.7.0!
# RUN mkdir /root/.zcash-params \
#   && wget "https://download.z.cash/downloads/sprout-groth16.params" -O "/root/.zcash-params/sprout-groth16.params"

ARG TARGETPLATFORM
ARG TAG
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCH="arm64"; else ARCH="x86_64"; fi \
  && wget "https://octez.tezos.com/releases/octez-$TAG/binaries/$ARCH/octez-node" -O "octez-node" \
  && chmod +x octez-node \
  && ln -s octez-node tezos-node
#RUN ./tezos-node identity generate "0.0" --data-dir /tezos/sandbox
COPY ./sandbox.json /tezos/
COPY ./identity.json /tezos/sandbox/
ENTRYPOINT ["/tezos/octez-node", "run", \
    "-vv", \
    "--data-dir=/tezos/sandbox", \
    "--synchronisation-threshold=0", \
    "--sandbox=/tezos/sandbox.json", \
    "--allow-all-rpc=0.0.0.0", \
    "--rpc-addr=0.0.0.0:8732"]