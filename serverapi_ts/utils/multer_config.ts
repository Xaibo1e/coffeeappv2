import { Request } from "express"
import multer, { FileFilterCallback } from "multer"
import fs from "fs"
import path from "path"

const storage = multer.diskStorage({
  destination: (
    req: Request,
    file: Express.Multer.File,
    callback: (error: Error | null, destination: string) => void
  ) => {
    const folder = path.join(__dirname, "../uploads/images")

    // ตรวจสอบและสร้างโฟลเดอร์ recursive
    if (!fs.existsSync(folder)) {
      fs.mkdirSync(folder, { recursive: true })
    }

    callback(null, folder)
  },
  filename: (
    req: Request,
    file: Express.Multer.File,
    callback: (error: Error | null, filename: string) => void
  ) => {
    const ext = file.mimetype.split("/")[1] || "jpg"
    callback(null, `${file.fieldname}-${Date.now()}.${ext}`)
  },
})

const fileFilter = (
  req: Request,
  file: Express.Multer.File,
  callback: FileFilterCallback
) => {
  // ยอมรับไฟล์ถ้า mimetype ขึ้นต้นด้วย image/ หรือส่งมาจาก Flutter เป็น octet-stream
  const isImage = 
    file.mimetype.startsWith("image/") ||
    file.mimetype === "application/octet-stream" ||
    /\.(jpg|jpeg|png|webp|gif)$/i.test(file.originalname || "")

  if (isImage) {
    callback(null, true)
  } else {
    callback(new Error("Only image files are allowed!"))
  }
}

const multerConfig = {
  config: {
    storage: storage,
    limits: { fileSize: 1024 * 1024 * 10 },
    fileFilter: fileFilter,
  },
  keyUpload: "photo", // ต้องเป็น "photo" ตัวพิมพ์เล็กเป๊ะๆ
}

export default multerConfig