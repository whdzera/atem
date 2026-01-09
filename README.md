<img align="center" width="150" src="https://i.imgur.com/Fgolqn1.png" />

![Lang](https://img.shields.io/badge/language-ruby-red)
![Lang](https://img.shields.io/badge/language-javascript-yellow)

# Atem Bot

A discord, Telegram, and Whatsapp bot for search yugioh card, written in ruby and javascript.

APIs from Ygoprodeck

### Website

https://atem.whdzera.my.id/

> !! READ
> !! The Whatsapp bot version is no longer being developed.

### Usage

| Commands    | Discord   | Telegram  | Whatsapp  |
| ----------- | --------- | --------- | --------- |
| information | `/info`   | `/info`   | `/info`   |
| help        | `/help`   | `/help`   | `/help`   |
| ping        | `/ping`   | `/ping`   | `/ping`   |
| random card | `/random` | `/random` | `/random` |
| art card    | `/art`    | `/art`    | `/art`    |
| image card  | `/img`    | `/img`    | `/img`    |
| list card   | `/list`   | `/list`   | `/list`   |
| search card | `/search` | `/search` | `/search` |
| tier list   | `/tier`   | `/tier`   | `/tier`   |

### View

![](https://i.imgur.com/QcedrlV.png)

<img align="center" width="350" src="https://i.imgur.com/SS9VM9L.gif" />

### Prerequisite

- Ruby 2.7.0^
- Node 18.20.8^

install all dependency

```
bundle install && npm install
```

### Run Bot

All

```
./bin/START
```

Discord

```
rake discord
```

Telegram

```
rake telegram
```

Whatsapps

```
rake wa
```

unit test

```
rake test
```

## Contributing

1. Fork the repository.
2. Create a new branch: `git checkout -b feature-branch`
3. Make your changes and commit them: `git commit -m 'Add new feature'`
4. Push to the branch: `git push origin feature-branch`
5. Create a pull request.

## License

This project is licensed under the Apache License.

## Contact

For any questions or suggestions, feel free to open an issue on GitHub.
