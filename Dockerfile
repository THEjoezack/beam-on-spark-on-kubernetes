FROM maven:3.6.3-jdk-11 as build

WORKDIR /app
RUN mvn archetype:generate \
  -DarchetypeGroupId=org.apache.beam \
  -DarchetypeArtifactId=beam-sdks-java-maven-archetypes-examples \
  -DarchetypeVersion=2.21.0 \
  -DgroupId=org.example \
  -DartifactId=word-count-beam \
  -Dversion="0.1" \
  -Dpackage=org.apache.beam.examples \
  -DinteractiveMode=false

WORKDIR /app/word-count-beam
RUN mvn package -P spark-runner

FROM gcr.io/spark-operator/spark:v2.4.5

COPY --from=build /app/word-count-beam/target/word-count-beam-bundled-0.1.jar /lib/word-count-beam-0.1-shaded.jar
RUN mkdir /data
RUN mkdir /data/output
USER 0

RUN echo "Grabbing 1gb of random data, this will take a bit"
RUN head -c 1G </dev/urandom >/data/input.txt
