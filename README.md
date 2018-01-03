## EXPERIMENTAL!

Please note this sample application is under development, and you might find some code that's not finalized, yet.

We will announce the presentable version [on Facebook](http://fb.me/trailblazer.to).

## Configuration

Tamarama uses the `dotenv` gem for managing environment variables such as database connection strings.

For you, this boils down to providing `.env.development` and `.env.test` files in the project root. Check out `example.env.test` for an example of what such a config file might look like.

```ruby
# .env.test
DATABASE_URL="postgres://user:password@localhost/myblog_test"
```

## Development

```
rerun -- rackup -p 9999
```

## Migrations

```
RACK_ENV=test rake db:migrate
RACK_ENV=test rake db:migrate[0]
```

## Testing Connection

```
RACK_ENV=test rake db:debug
```

## Backup

```ruby
pg_dump -U trbinc exp_production -W -h 127.0.0.1  >> BACKUP/__db.sql
rsync /var/www/exp/shared/uploads/ -av BACKUP/
```


## TODO

* reading twin (e.g. for form presentation) shouldn't coerce!

* unique invoice number (or warning)
* unique description (e.g. booking number, with warning!)
  trim invoice number
* unit_price: remove ,
* date: any format
* unique file upload name ( rename to invoice/id or something)
