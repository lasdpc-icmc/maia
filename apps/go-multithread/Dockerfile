FROM golang:1.8-alpine
ADD . /go/src/main
RUN go install main

FROM alpine:latest
COPY --from=0 /go/bin/main .
ENV PORT 8080
CMD ["./main"]
