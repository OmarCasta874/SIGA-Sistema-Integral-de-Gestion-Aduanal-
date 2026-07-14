from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0005_pedimento_fecha_limite'),
    ]

    operations = [
        migrations.RunSQL(
            sql="ALTER TABLE cliente ADD COLUMN activo TINYINT(1) NOT NULL DEFAULT 1;",
            reverse_sql="ALTER TABLE cliente DROP COLUMN activo;",
        ),
    ]
