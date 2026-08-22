from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0014_aduanas_data'),
    ]

    operations = [
        migrations.RunSQL(
            sql="ALTER TABLE pedimento MODIFY permiso VARCHAR(30) NULL;",
            reverse_sql="ALTER TABLE pedimento MODIFY permiso VARCHAR(30) NOT NULL;",
        ),
    ]
