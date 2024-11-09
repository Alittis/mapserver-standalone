from fastapi import FastAPI, HTTPException
import mapscript

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the MapServer FastAPI API"}

@app.get("/render_map/")
def render_map():
    try:
        # Example MapScript setup: load the map and render
        mapfile = "/var/www/html/slovenia.map"  # Path to your mapfile
        map_obj = mapscript.mapObj(mapfile)
        img = map_obj.draw()  # Render the map image
        img_path = "/app/output.png"
        img.save(img_path)  # Save the rendered map to a file
        return {"message": f"Map rendered and saved to {img_path}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Map rendering failed: {e}")