# Custom docling-serve image (CUDA 12.8) with the SmolVLM-256M-Instruct
# picture-description model baked in for fully offline/air-gapped operation.
#
# CUDA images are NOT tagged `latest`; pick an explicit version tag or `main`.
# See: https://quay.io/repository/docling-project/docling-serve-cu128?tab=tags
ARG BASE_IMAGE=quay.io/docling-project/docling-serve-cu128:v1.36.0
FROM ${BASE_IMAGE}

# HuggingFace repo id to prefetch. `smolvlm` is docling's preset name for
# HuggingFaceTB/SmolVLM-256M-Instruct (the default picture-description model).
ARG MODELS_LIST="smolvlm"

# The base image already defines DOCLING_SERVE_ARTIFACTS_PATH and runs as
# USER 1001 (WORKDIR /opt/app-root/src), so the download lands next to the
# models that ship with the base image and is owned by the runtime user.
RUN echo "Downloading models: ${MODELS_LIST}" && \
    HF_HUB_DOWNLOAD_TIMEOUT=90 \
    HF_HUB_ETAG_TIMEOUT=90 \
    docling-tools models download -o "${DOCLING_SERVE_ARTIFACTS_PATH}" ${MODELS_LIST} && \
    chmod -R g=u "${DOCLING_SERVE_ARTIFACTS_PATH}"

# Inherit ENTRYPOINT/CMD (`docling-serve run`) and EXPOSE 5001 from the base image.
