from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0002_aduana_arancel_bitacora_categoriaproductos_and_more'),
    ]

    operations = [
        migrations.RunSQL(
            sql=[
                "ALTER TABLE usuario ADD COLUMN rol VARCHAR(20) NOT NULL DEFAULT 'Agente Aduanal';",
                "ALTER TABLE usuario ADD COLUMN activo TINYINT(1) NOT NULL DEFAULT 1;",
            ],
            reverse_sql=[
                "ALTER TABLE usuario DROP COLUMN rol;",
                "ALTER TABLE usuario DROP COLUMN activo;",
            ],
        ),
    ]
