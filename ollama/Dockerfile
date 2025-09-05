FROM dustynv/ollama:0.6.8-r36.4-cu126-22.04
ENV PIP_INDEX_URL=https://pypi.jetson-ai-lab.io/jp6/cu126
ENV OLLAMA_VERSION=0.11.10
RUN curl -fsSL https://ollama.com/install.sh | sh

ADD entrypoint.sh .

# Set the entrypoint
ENTRYPOINT ["bash", "entrypoint.sh"]