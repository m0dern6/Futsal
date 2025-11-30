using System.Security.Claims;
using FutsalApi.Data.Models;
using Microsoft.AspNetCore.Identity;
using FutsalApi.ApiService.Repositories;
using FutsalApi.Data.DTO;

namespace FutsalApi.ApiService.Services
{
    public class ImageService
    {
        private readonly IImageRepository _imageRepository;
        private readonly IWebHostEnvironment _env;
        private readonly UserManager<User> _userManager;
        public ImageService(IImageRepository imageRepository, IWebHostEnvironment env, UserManager<User> userManager)
        {
            _imageRepository = imageRepository;
            _env = env;
            _userManager = userManager;
        }

        public async Task<Image> UploadSingleFile(User user, IFormFile file)
        {
            string? userId = user?.Id;

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

        public async Task<List<Image>> UploadMultipleFiles(User user, List<IFormFile> files)
        {
            var uploadedImages = new List<Image>();
            foreach (var file in files)
            {
                uploadedImages.Add(await UploadSingleFile(user, file));
            }
            return uploadedImages;
        }

        public async Task<bool> DeleteSingleFile(User user, string imageUrl)
        {
            string? userId = user?.Id;

            var image = await _imageRepository.GetByIdAsync(i => (i.FilePath == imageUrl || i.FileName == imageUrl) && i.UserId == userId && !i.IsDeleted);
            if (image == null)
            {
                return false;
            }
            _imageRepository.Delete(image);
            await _imageRepository.SaveChangesAsync();
            var filePath = Path.Combine(_env.WebRootPath, image.FilePath.TrimStart('/'));
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }

            return true;
        }

        public async Task<bool> DeleteMultipleFiles(User user, List<string> imageUrls)
        {
            bool allDeleted = true;
            foreach (var imageUrl in imageUrls)
            {
                if (!await DeleteSingleFile(user, imageUrl))
                {
                    allDeleted = false;
                }
            }
            return allDeleted;
        }

        public async Task<List<Image>> GetImagesByUserId(User user)
        {
            string? userId = user?.Id;
            return await _imageRepository.GetImagesByUserIdAsync(userId);
        }
    }
}