using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace GraphicsPractical2
{
    public class Game1 : Microsoft.Xna.Framework.Game
    {
        // Often used XNA objects
        private GraphicsDeviceManager graphics;
        private SpriteBatch spriteBatch;
        private FrameRateCounter frameRateCounter;

        // Game objects and variables
        private Camera camera;
        
        // Model
        private Model model;
        private Material modelMaterial;

        // Quad
        private VertexPositionNormalTexture[] quadVertices;
        private short[] quadIndices;
        private Matrix quadTransform;
        // added: the effect for the quad. Since there is no model-object-equivalent for the quad,
        // added: we must store it's effect locally
        Effect QuadEffect;

        public Game1()
        {
            this.graphics = new GraphicsDeviceManager(this);
            this.Content.RootDirectory = "Content";
            // Create and add a frame rate counter
            this.frameRateCounter = new FrameRateCounter(this);
            this.Components.Add(this.frameRateCounter);
        }

        protected override void Initialize()
        {
            // Copy over the device's rasterizer state to change the current fillMode
            this.GraphicsDevice.RasterizerState = new RasterizerState() { CullMode = CullMode.None };
            // Set up the window
            this.graphics.PreferredBackBufferWidth = 800;
            this.graphics.PreferredBackBufferHeight = 600;
            this.graphics.IsFullScreen = false;
            // Let the renderer draw and update as often as possible
            this.graphics.SynchronizeWithVerticalRetrace = false;
            this.IsFixedTimeStep = false;
            // Flush the changes to the device parameters to the graphics card
            this.graphics.ApplyChanges();
            // Initialize the camera
            this.camera = new Camera(new Vector3(0, 50, 100), new Vector3(0, 0, 0), new Vector3(0, 1, 0));

            this.IsMouseVisible = true;
            
            base.Initialize();
        }

        protected override void LoadContent()
        {
            // Create a SpriteBatch object
            this.spriteBatch = new SpriteBatch(this.GraphicsDevice);
            // Load the "Simple" effect
            Effect effect = this.Content.Load<Effect>("Effects/Simple");
                        
            // added: create a new material object and set AmbientColor and AmbientIntensity
            modelMaterial = new Material();
            modelMaterial.AmbientColor = Color.Red;
            modelMaterial.AmbientIntensity = 0.2f;
            // added: set the DiffuseColor to Red
            modelMaterial.DiffuseColor = Color.Red;

            // added: added the specular variables
            modelMaterial.SpecularColor = Color.White;
            modelMaterial.SpecularIntensity = 2.0f;
            modelMaterial.SpecularPower = 25.0f;
            
            // added: set the parameters to the effect
            modelMaterial.SetEffectParameters(effect);

            // Load the model and let it use the "Simple" effect
            this.model = this.Content.Load<Model>("Models/Teapot");
            this.model.Meshes[0].MeshParts[0].Effect = effect;

            // Setup the quad
            this.setupQuad();

            // added: load the "Simple2" effect for the quad
            QuadEffect = this.Content.Load<Effect>("Effects/Simple2");
            // added: load the texture to the QuadEffect
            QuadEffect.Parameters["DiffuseTexture"].SetValue(Content.Load<Texture>("Textures\\CobbleStonesDiffuse"));
        }

        /// <summary>
        /// Sets up a 2 by 2 quad around the origin.
        /// </summary>
        private void setupQuad()
        {
            float scale = 50.0f;

            // Normal points up
            Vector3 quadNormal = new Vector3(0, 1, 0);

            this.quadVertices = new VertexPositionNormalTexture[4];
            // Top left
            this.quadVertices[0].Position = new Vector3(-1, 0, -1);
            this.quadVertices[0].Normal = quadNormal;
            this.quadVertices[0].TextureCoordinate = new Vector2(0, 0);
            // Top right
            this.quadVertices[1].Position = new Vector3(1, 0, -1);
            this.quadVertices[1].Normal = quadNormal;
            this.quadVertices[1].TextureCoordinate = new Vector2(1, 0);
            // Bottom left
            this.quadVertices[2].Position = new Vector3(-1, 0, 1);
            this.quadVertices[2].Normal = quadNormal;
            this.quadVertices[2].TextureCoordinate = new Vector2(0, 1);
            // Bottom right
            this.quadVertices[3].Position = new Vector3(1, 0, 1);
            this.quadVertices[3].Normal = quadNormal;
            this.quadVertices[3].TextureCoordinate = new Vector2(1, 1);

            this.quadIndices = new short[] { 0, 1, 2, 1, 2, 3 };
            this.quadTransform = Matrix.CreateScale(scale);
        }

        protected override void Update(GameTime gameTime)
        {
            float timeStep = (float)gameTime.ElapsedGameTime.TotalSeconds * 60.0f;

            // Update the window title
            this.Window.Title = "XNA Renderer | FPS: " + this.frameRateCounter.FrameRate;

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            // Clear the screen in a predetermined color and clear the depth buffer
            this.GraphicsDevice.Clear(ClearOptions.Target | ClearOptions.DepthBuffer, Color.DeepSkyBlue, 1.0f, 0);

            // added: set the technique of the quad
            this.QuadEffect.CurrentTechnique = QuadEffect.Techniques["Simple"];
            // Matrices for 3D perspective projection
            this.camera.SetEffectParameters(QuadEffect);
            this.QuadEffect.Parameters["World"].SetValue(Matrix.CreateScale(100.0f));

            // added: draw the quad
            this.DrawQuad();
            
            // Get the model's only mesh
            ModelMesh mesh = this.model.Meshes[0];
            Effect effect = mesh.Effects[0];

            // Set the effect parameters
            effect.CurrentTechnique = effect.Techniques["Simple"];
            // Matrices for 3D perspective projection
            this.camera.SetEffectParameters(effect);

            // added: create the world matrix for the teacup
            Matrix World = Matrix.CreateScale(10.0f);
            // added: translate the world matrix
            Matrix TranslatedWorld = World * Matrix.CreateTranslation(0.0f, 16f, 0.0f);

            // added: set the new world matrix to the effect for the teacup
            effect.Parameters["World"].SetValue(TranslatedWorld);

            // added: calculate the inversed transposed world matrix, to fix non-uniform scaling for normals
            effect.Parameters["InverseTransposeWorld"].SetValue(Matrix.Transpose(Matrix.Invert(TranslatedWorld)));

            // Draw the model
            mesh.Draw();

            base.Draw(gameTime);
        }

        protected void DrawQuad()
        {
            // added: apply effect passes
            foreach (EffectPass pass in this.QuadEffect.CurrentTechnique.Passes)
            {
                pass.Apply();
            }

            // added: draw the quad using the QuadEffect
            this.GraphicsDevice.DrawUserIndexedPrimitives(PrimitiveType.TriangleList, this.quadVertices, 0, this.quadVertices.Length, this.quadIndices, 0, this.quadIndices.Length / 3);
        }
    }
}
