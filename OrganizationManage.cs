using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using TelGws.Data.Database;
using TelGws.Data.Models;
namespace TelGws.Services
{
    public class OrganizationManage {
        public static (Organization, string) Get(int id)
        {
            using (var context = SiteHelper.CreateDbContext())
            {
                var parameters = new SqlParameter[]
                {
                               new(){  ParameterName="@Id", Value= id},
                               new(){ ParameterName="@ErrorMessage",Direction=System.Data.ParameterDirection.Output,Size=-1,SqlDbType=System.Data.SqlDbType.VarChar}
                };
                var data = context.Organization.FromSqlRaw("EXECUTE [OrganizationGet] @Id, @ErrorMessage OUTPUT", parameters).ToList().FirstOrDefault();
                var message = parameters.First(param => param.ParameterName == "@ErrorMessage");
                var errorMessage = message.Value;
                return (data, Convert.ToString(errorMessage));
            }
        }
        public static List<Organization> GetAll()
        {
            using (var context = SiteHelper.CreateDbContext())
                return context.Organization.FromSqlRaw("EXECUTE [OrganizationGetAll]").ToList();
        }
        public static (bool, string) Set(Organization _Organization)
        {
            using (var context = SiteHelper.CreateDbContext()) {
                var parameters = new SqlParameter[]{
                                new(){ ParameterName="@Id", Value= _Organization.Id },
                                new(){ ParameterName="@SiteId", Value= _Organization.SiteId },
                                new(){ ParameterName="@Name", Value= _Organization.Name },
                                new(){ ParameterName="@AbbreviatedName", Value= _Organization.AbbreviatedName },
                                new(){ ParameterName="@PhysicalStreetAddress", Value= _Organization.PhysicalStreetAddress },
                                new(){ ParameterName="@PhysicalPostalCode", Value= _Organization.PhysicalPostalCode },
                                new(){ ParameterName="@PhysicalState", Value= _Organization.PhysicalState },
                                new(){ ParameterName="@PhysicalCity", Value= _Organization.PhysicalCity },
                                new(){ ParameterName="@PhysicalTown", Value= _Organization.PhysicalTown },
                                new(){ ParameterName="@ShippingStreetAddress", Value= _Organization.ShippingStreetAddress },
                                new(){ ParameterName="@ShippingPostalCode", Value= _Organization.ShippingPostalCode },
                                new(){ ParameterName="@ShippingState", Value= _Organization.ShippingState },
                                new(){ ParameterName="@ShippingCity", Value= _Organization.ShippingCity },
                                new(){ ParameterName="@ShippingTown", Value= _Organization.ShippingTown },
                                new(){ ParameterName="@TelephoneNumber", Value= _Organization.TelephoneNumber },
                                new(){ ParameterName="@FaxNumber", Value= _Organization.FaxNumber },
                                new(){ ParameterName="@ProjectCodeRequired", Value= _Organization.ProjectCodeRequired },
                                new(){ ParameterName="@Status", Value= _Organization.Status },
                                new(){ ParameterName="@ImportLogId", Value= _Organization.ImportLogId },
                                new(){ ParameterName="@CreatedBy", Value= _Organization.CreatedBy },
                                new(){ ParameterName="@CreatedOn", Value= _Organization.CreatedOn },
                                new(){ ParameterName="@ModifiedBy", Value= _Organization.ModifiedBy },
                                new(){ ParameterName="@ModifiedOn", Value= _Organization.ModifiedOn },
                                new(){ ParameterName="@ErrorMessage",Direction=System.Data.ParameterDirection.Output,Size=-1,SqlDbType=System.Data.SqlDbType.VarChar}
                                };
                var result = context.Database.ExecuteSqlRaw(@"EXECUTE [OrganizationSet] @Id,
                                                @SiteId,
                                                @Name,
                                                @AbbreviatedName,
                                                @PhysicalStreetAddress,
                                                @PhysicalPostalCode,
                                                @PhysicalState,
                                                @PhysicalCity,
                                                @PhysicalTown,
                                                @ShippingStreetAddress,
                                                @ShippingPostalCode,
                                                @ShippingState,
                                                @ShippingCity,
                                                @ShippingTown,
                                                @TelephoneNumber,
                                                @FaxNumber,
                                                @ProjectCodeRequired,
                                                @Status,
                                                @ImportLogId,
                                                @CreatedBy,
                                                @CreatedOn,
                                                @ModifiedBy,
                                                @ModifiedOn,
                                                @ErrorMessage OUTPUT", parameters);
                var message = parameters.First(param => param.ParameterName == "@ErrorMessage");
                var errorMessage = message.Value;
                return (result > 0, Convert.ToString(errorMessage));
            }
        }
        public static (string, string) Delete(int id)
        {
            using (var context = SiteHelper.CreateDbContext()) {
                var parameters = new SqlParameter[]{
                                new(){ ParameterName="@Id", Value= id },
                                new(){ ParameterName="@ErrorMessage",Direction=System.Data.ParameterDirection.Output,Size=-1,SqlDbType=System.Data.SqlDbType.VarChar}
                                };
                var result = context.Database.ExecuteSqlRaw("EXECUTE [OrganizationDelete] @Id,@ErrorMessage OUTPUT", parameters);
                var message = parameters.First(param => param.ParameterName == "@ErrorMessage");
                if (Convert.ToString(message.Value) != string.Empty)
                    return (string.Empty, (string)message.Value);
                else
                    return (string.Empty, null);
            }
        }
    }
}