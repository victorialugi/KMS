# Домашнее задание к занятию "`Безопасность в облачных провайдерах`" - `Лугинина Виктория`

## Что сделано

- Ключ KMS `bucket-key`
- Бакет `victoria-luginina-site-20261021` с шифрованием объектов этим ключом
- Статический сайт в бакете `victoria-luginina-web-20261021`
- Страница: http://victoria-luginina-web-20261021.website.yandexcloud.net

Сайт и шифрование разведены по разным бакетам: объекты, зашифрованные KMS, анонимно не открываются, поэтому публичная страница лежит в отдельном бакете без шифрования.

## HTTPS

Замочка нет. Адрес `*.website.yandexcloud.net` работает только по HTTP. Для HTTPS и замочка нужен собственный домен и сертификат в Certificate Manager.

## Манифесты

- [main.tf](https://github.com/victorialugi/KMS/blob/main/main.tf)
- [variables.tf](https://github.com/victorialugi/KMS/blob/main/variables.tf)
- [versions.tf](https://github.com/victorialugi/KMS/blob/main/versions.tf)

## Скрины

Сайт:

![1.png](https://github.com/victorialugi/KMS/blob/main/1.png)

Шифрование KMS:

![2.png](https://github.com/victorialugi/KMS/blob/main/2.png)
