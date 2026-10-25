# Template only: the assignment says the application is a black box.
# Add the supplied application build context before building an image.
# Do not use this file as-is until the application runtime is known.
FROM alpine:3.20
LABEL org.opencontainers.image.title="immverse-assignment-placeholder"
CMD ["sh", "-c", "echo 'Replace this placeholder with the supplied API or worker image'; sleep 3600"]
