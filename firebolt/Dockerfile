FROM ghcr.io/gdcs-org/prod/base/dac:latest
ENV FIREBOLT_CONTROLLER_SOCKET=/var/run/usp/broker_agent_path
ENV FIREBOLT_AGENT_SOCKET=/var/run/usp/broker_controller_path
COPY ./greeter.py /app/greeter.py
ENTRYPOINT ["python3", "/app/greeter.py"]
