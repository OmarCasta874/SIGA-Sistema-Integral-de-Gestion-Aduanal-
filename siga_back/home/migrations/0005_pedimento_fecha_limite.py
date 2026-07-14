from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0004_bitacora_usuario_modulo_tipo_accion'),
    ]

    operations = [
        migrations.RunSQL(
            sql="ALTER TABLE pedimento ADD COLUMN fecha_limite DATETIME NULL;",
            reverse_sql="ALTER TABLE pedimento DROP COLUMN fecha_limite;",
        ),
    ]
