from django.db import models
from django.utils.translation import ugettext as _

# Create your models here.
class Institution(models.Model):
  
    name = models.CharField(max_length=250)
    short_name = models.CharField(max_length=100, blank=True)
    main_phone = models.CharField(max_length=25)
    sec_phone = models.CharField(max_length=25, blank=True)
    address = models.TextField()
    mngt_email = models.EmailField(unique=True)
    idp_address = models.URLField(null=True, blank=True)
  
    class Meta:
        permissions = (
            ("delegate_institution_mngt", _("Can delegate institution management tasks")),
            ("revoke_institution_mngt", _("Can revoke institution management tasks")),
            ("delegate_election_mngt", _("Can delegate election management tasks")),
            ("revoke_election_mngt", _("Can revoke election management tasks")),
    )

    def __unicode__(self):
        return self.name
  
    @property
    def institution_admin(self):
        try:
            return InstitutionUserProfile.objects.get(email=self.mngt_email)
        except InstitutionUserProfile.DoesNotExist:
            return None


    @property
    def institution_users(self):
        users = []
        for user in self.institutionuserprofile_set.all():
            users.append({
                'user': user.user,
                'email': user.email,
                'role': user.institution_role,
                'active': user.active,
                'expires_at': user.expires_at,
            })
        
        return users


class InstitutionUserProfile(models.Model):

    helios_user = models.ForeignKey('helios_auth.User', blank=True, default=None, null=True)
    institution = models.ForeignKey("heliosinstitution.Institution")
    email = models.EmailField()
    expires_at = models.DateTimeField(auto_now_add=False, default=None, null=True, blank=True)
    active = models.BooleanField(default=False)
  
    def __unicode__(self):
        return self.helios_user.name if self.helios_user is not None else self.email

    @property
    def is_institution_admin(self):
        if self.institution.mngt_email == self.email:
            return True
        return False
    
    @property
    def institution_role(self):
        #TODO: check for user group instead
        if self.is_institution_admin:
            return _("Admin")
        if self.helios_user and self.helios_user.admin_p:
            return _("Election Admin")
        return _("Undefined")
