using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace TelGws.Services.Utility
{
    public static class SqlHelper
    {
        static string _connectionString;
        static SqlHelper()
        {
            var configuration = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();
            _connectionString = configuration.GetValue<string>("ConnectionStrings:SQLConnection");
        }

        static SqlConnection SqlConnection { get { return new SqlConnection(_connectionString); } }

        public static int ExecuteQuery(string query, SqlParameter[] sqlParameters = null)
        {
            var sqlCommand = new SqlCommand(query);
            if (sqlParameters != null && sqlParameters.Length > 0)
                sqlCommand.Parameters.AddRange(sqlParameters);
            return sqlCommand.ExecuteQuery();
        }

        public static int ExecuteQuery(this SqlCommand sqlCommand)
        {
            sqlCommand.Connection = SqlConnection;
            SqlConnection.Open();
            var result = sqlCommand.ExecuteNonQuery();
            SqlConnection.Close();
            sqlCommand.Dispose();
            SqlConnection.Dispose();
            return result;
        }

        public static List<T> GetAll<T>(this SqlCommand sqlCommand)
        {
            sqlCommand.Connection = SqlConnection;
            SqlConnection.Open();
            var dr = sqlCommand.ExecuteReader();
            var lst = new List<T>();
            while (dr.Read())
                lst.Add((T)Activator.CreateInstance(typeof(T), dr));
            SqlConnection.Close();
            sqlCommand.Dispose();
            SqlConnection.Dispose();
            return lst;
        }

        public static T Get<T>(this SqlCommand sqlCommand)
        {
            sqlCommand.Connection = SqlConnection;
            SqlConnection.Open();
            var dr = sqlCommand.ExecuteReader();
            T src = default;
            if (dr.Read())
                src = (T)Activator.CreateInstance(typeof(T), dr);
            SqlConnection.Close();
            sqlCommand.Dispose();
            SqlConnection.Dispose();
            return src;
        }
    }
}
