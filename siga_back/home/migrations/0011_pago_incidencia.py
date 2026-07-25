from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0010_datos_clientes_pedimentos'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE pago
                ADD COLUMN incidencia INT NULL,
                ADD CONSTRAINT fk_pago_incidencia
                    FOREIGN KEY (incidencia) REFERENCES incidencia(codigo)
                    ON DELETE SET NULL;
            """,
            reverse_sql="""
                ALTER TABLE pago
                DROP FOREIGN KEY fk_pago_incidencia,
                DROP COLUMN incidencia;
            """,
        ),
    ]
