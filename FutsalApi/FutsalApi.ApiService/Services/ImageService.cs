using FutsalApi.Core.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using FutsalApi.Auth.Models;
using Microsoft.AspNetCore.Identity;

namespace FutsalApi.ApiService.Services
{
    public class ImageService
    {
        private readonly IImageRepository _imageRepository;
        private readonly IWebHostEnvironment _env;
        private readonly UserManager<User> _userManager;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ImageService(IImageRepository imageRepository, IWebHostEnvironment env, UserManager<User> userManager, IHttpContextAccessor httpContextAccessor)
        {
            _imageRepository = imageRepository;
            _env = env;
            _userManager = userManager;
            _httpContextAccessor = httpContextAccessor;
        }

        private string GetCurrentUserId()
        {
            return _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }

        public async Task<Image> UploadSingleFile(IFormFile file)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
            {
                throw new UnauthorizedAccessException("User not authenticated.");
            }

            var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads");
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            var uniqueFileName = Guid.NewGuid().ToString() + "_" + file.FileName;
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(fileStream);
            }

            var image = new Image
            {
                FileName = uniqueFileName,
                FilePath = "/uploads/" + uniqueFileName,
                FileType = file.ContentType,
                Size = file.Length,
                UploadedAt = DateTime.UtcNow,
                UserId = userId,
                IsDeleted = false
            };

            _imageRepository.Add(image);
            await _imageRepository.SaveChangesAsync();

            return image;
        }

        public async Task<List<Image>> UploadMultipleFiles(List<IFormFile> files)
        {
            var uploadedImages = new List<Image>();
            foreach (var file in files)
            {
                uploadedImages.Add(await UploadSingleFile(file));
            }
            return uploadedImages;
        }

        public async Task<bool> DeleteSingleFile(int imageId)
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
            {
                throw new UnauthorizedAccessException("User not authenticated.");
            }

            var image = await _imageRepository.GetByIdAsync(i => i.Id == imageId && i.UserId == userId && !i.IsDeleted);
            if (image == null)
            {
                return false;
            }

            // Mark as deleted in DB
            image.IsDeleted = true;
            _imageRepository.Update(image);
            await _imageRepository.SaveChangesAsync();

            // Optionally delete from file system (consider soft delete first)
            var filePath = Path.Combine(_env.WebRootPath, image.FilePath.TrimStart('/'));
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }

            return true;
        }

        public async Task<bool> DeleteMultipleFiles(List<int> imageIds)
        {
            bool allDeleted = true;
            foreach (var imageId in imageIds)
            {
                if (!await DeleteSingleFile(imageId))
                {
                    allDeleted = false;
                }
            }
            return allDeleted;
        }

        public async Task<List<Image>> GetImagesByUserId()
        {
            var userId = GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
            {
                throw new UnauthorizedAccessException("User not authenticated.");
            }

            return await _imageRepository.Where(i => i.UserId == userId && !i.IsDeleted).ToListAsync();
        }
    }
}