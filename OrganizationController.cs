using Microsoft.AspNetCore.Mvc;
using TelGws.API.Infrastructures;
using TelGws.Data.Models;
using TelGws.Services;

namespace TelGws.API.Controllers.SiteSpecific
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrganizationController : TelBaseController
    {
        [HttpGet("getall")]
        public IActionResult OrganizationGetAll()
        {

            var result = OrganizationManage.GetAll();
            if (result == null)
                return Json(GetAjaxResponse(false, "No record found."));

            return Json(GetAjaxResponse(true, string.Empty, result));
        }
        [HttpGet("get")]
        public IActionResult OrganizationGet(int id)
        {
            var (result, message) = OrganizationManage.Get(id);

            if (!string.IsNullOrEmpty(message))
                return Json(GetAjaxResponse(false, message));

            return Json(GetAjaxResponse(true, string.Empty, result));
        }
        [HttpPost("set")]
        public IActionResult OrganizationSet(Organization param)
        {
            var (result, error) = OrganizationManage.Set(param);
            if (!string.IsNullOrEmpty(error))
                return Json(GetAjaxResponse(false, error));

            return Json(GetAjaxResponse(true, string.Empty, result));
        }

        [HttpDelete("delete")]
        public IActionResult OrganizationDelete(int id)
        {
            var (result, error) = OrganizationManage.Delete(id);
            if (error != null)
                return Json(GetAjaxResponse(false, error));

            return Json(GetAjaxResponse(true, result ?? string.Empty));
        }
    }
}
