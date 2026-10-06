import { Request, Response } from "express"
import multer from "multer"
import multerConfig from "../utils/multer_config"
import connection from "../utils/db"

const upload = multer(multerConfig.config).single(multerConfig.keyUpload)

//----------------------------------------
// Get all products
//----------------------------------------
function getAllProducts(req: Request, res: Response) {
  try {
    connection.execute(
      "SELECT * FROM products ORDER BY id DESC",
      function (err, results) {
        if (err) {
          res.status(500).json({ status: "error", message: err.message || err })
          return
        } else {
          res.json(results)
        }
      }
    )
  } catch (err: any) {
    console.error("Error retrieving products: ", err)
    res.status(500).json({ status: "error", message: err.message || "Internal server error" })
  }
}

//----------------------------------------
// Get product by id
//----------------------------------------
function getProductById(req: Request, res: Response) {
  try {
    connection.execute(
      "SELECT * FROM products WHERE id = ?",
      [req.params.productId],
      function (err, results) {
        if (err) {
          res.status(500).json({ status: "error", message: err.message || err })
          return
        } else {
          res.json(results)
        }
      }
    )
  } catch (err: any) {
    console.error("Error retrieving product by id: ", err)
    res.status(500).json({ status: "error", message: err.message || "Internal server error" })
  }
}

//----------------------------------------
// Create product
//----------------------------------------
function createProduct(req: Request, res: Response) {
  upload(req, res, async (err: any) => {
    if (err) {
      const errorMessage = err.message || (err.code ? `Multer error: ${err.code}` : "File upload failed")
      console.error("Multer Upload Error (Create):", errorMessage)
      return res.status(500).json({ status: "error", message: errorMessage })
    }

    try {
      const {
        name,
        description,
        barcode,
        stock,
        price,
        category_id,
        user_id,
        status_id,
      } = req.body

      const image = req.file ? req.file.filename : null

      const sql =
        "INSERT INTO products (name, description, barcode, image, stock, price, category_id, user_id, status_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
      
      const values = [
        name,
        description ?? null,
        barcode,
        image,
        parseInt(stock, 10) || 0,
        parseInt(price, 10) || 0,
        parseInt(category_id, 10) || 1,
        parseInt(user_id, 10) || 1,
        parseInt(status_id, 10) || 1,
      ]

      connection.execute(sql, values, function (err, results: any) {
        if (err) {
          console.error("Database Insert Error:", err)
          res.status(500).json({ status: "error", message: err.message || err })
          return
        } else {
          res.json({
            status: "ok",
            message: "Product created successfully",
            product: {
              id: results.insertId,
              name: name,
              description: description,
              barcode: barcode,
              image: image,
              stock: parseInt(stock, 10) || 0,
              price: parseInt(price, 10) || 0,
              category_id: parseInt(category_id, 10) || 1,
              user_id: parseInt(user_id, 10) || 1,
              status_id: parseInt(status_id, 10) || 1,
            },
          })
        }
      })
    } catch (err: any) {
      console.error("Error storing product in the database: ", err)
      res.status(500).json({ status: "error", message: err.message || "Internal server error" })
    }
  })
}

//----------------------------------------
// Update product
//----------------------------------------
function updateProduct(req: Request, res: Response) {
  upload(req, res, async (err: any) => {
    if (err) {
      const errorMessage = err.message || (err.code ? `Multer error: ${err.code}` : "File upload failed")
      console.error("Multer Upload Error (Update):", errorMessage)
      return res.status(500).json({ status: "error", message: errorMessage })
    }

    try {
      connection.execute(
        "SELECT * FROM products WHERE id = ?",
        [req.params.productId],
        function (err, results: any) {
          if (err) {
            res.status(500).json({ status: "error", message: err.message || err })
            return
          }
          if (!results || results.length === 0) {
            res.status(404).json({ status: "error", message: "Product not found" })
            return
          }

          const current = results[0]
          const name = req.body.name ?? current.name
          const description = req.body.description ?? current.description
          const barcode = req.body.barcode ?? current.barcode
          const stock = req.body.stock !== undefined ? parseInt(req.body.stock, 10) : current.stock
          const price = req.body.price !== undefined ? parseInt(req.body.price, 10) : current.price
          const category_id = req.body.category_id !== undefined ? parseInt(req.body.category_id, 10) : current.category_id
          const user_id = req.body.user_id !== undefined ? parseInt(req.body.user_id, 10) : current.user_id
          const status_id = req.body.status_id !== undefined ? parseInt(req.body.status_id, 10) : current.status_id
          const image = req.file ? req.file.filename : current.image

          const sql =
            "UPDATE products SET name = ?, description = ?, barcode = ?, image = ?, stock = ?, price = ?, category_id = ?, user_id = ?, status_id = ? WHERE id = ?"
          
          const params = [
            name,
            description,
            barcode,
            image,
            stock,
            price,
            category_id,
            user_id,
            status_id,
            req.params.productId,
          ]

          connection.execute(sql, params, function (err) {
            if (err) {
              console.error("Database Update Error:", err)
              res.status(500).json({ status: "error", message: err.message || err })
              return
            } else {
              res.json({
                status: "ok",
                message: "Product updated successfully",
                product: {
                  id: Number(req.params.productId),
                  name: name,
                  description: description,
                  barcode: barcode,
                  image: image,
                  stock: stock,
                  price: price,
                  category_id: category_id,
                  user_id: user_id,
                  status_id: status_id,
                },
              })
            }
          })
        }
      )
    } catch (err: any) {
      console.error("Error updating product in the database: ", err)
      res.status(500).json({ status: "error", message: err.message || "Internal server error" })
    }
  })
}

//----------------------------------------
// Delete product
//----------------------------------------
function deleteProduct(req: Request, res: Response) {
  try {
    connection.execute(
      "DELETE FROM products WHERE id = ?",
      [req.params.productId],
      function (err) {
        if (err) {
          res.status(500).json({ status: "error", message: err.message || err })
          return
        } else {
          res.json({
            status: "ok",
            message: "Product deleted successfully",
            product: {
              id: Number(req.params.productId),
            },
          })
        }
      }
    )
  } catch (err: any) {
    console.error("Error deleting product from database: ", err)
    res.status(500).json({ status: "error", message: err.message || "Internal server error" })
  }
}

export {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
}