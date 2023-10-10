FROM dart

WORKDIR /usr/src/app

COPY . .

RUN mkdir exe

RUN dart pub get

RUN dart compile exe bin/visit_counter.dart -o exe/visit_counter

EXPOSE 8080

CMD ["./exe/visit_counter"]